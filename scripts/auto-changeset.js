#!/usr/bin/env node

/**
 * 自动生成 changeset 的脚本
 * 基于 PR 信息和 commit 分析
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * 分析 commit messages 来判断版本类型
 */
function analyzeCommits(baseBranch = 'main') {
  try {
    // 获取 PR 中的所有 commits
    const commits = execSync(`git log ${baseBranch}..HEAD --oneline`, { encoding: 'utf-8' });
    
    let versionType = 'patch';
    const changes = [];
    
    commits.split('\n').forEach(commit => {
      if (!commit) return;
      
      // 根据 conventional commits 规范分析
      if (commit.includes('BREAKING CHANGE:') || commit.includes('!:')) {
        versionType = 'major';
        changes.push(`💥 ${commit}`);
      } else if (commit.match(/^[a-f0-9]+ feat(\(.+?\))?:/)) {
        if (versionType !== 'major') versionType = 'minor';
        changes.push(`✨ ${commit}`);
      } else if (commit.match(/^[a-f0-9]+ fix(\(.+?\))?:/)) {
        changes.push(`🐛 ${commit}`);
      } else if (commit.match(/^[a-f0-9]+ perf(\(.+?\))?:/)) {
        if (versionType === 'patch') versionType = 'minor';
        changes.push(`⚡ ${commit}`);
      } else {
        changes.push(`📝 ${commit}`);
      }
    });
    
    return { versionType, changes };
  } catch (error) {
    console.error('Failed to analyze commits:', error);
    return { versionType: 'patch', changes: [] };
  }
}

/**
 * 分析文件变化来补充判断
 */
function analyzeFiles(baseBranch = 'main') {
  try {
    const files = execSync(`git diff ${baseBranch}..HEAD --name-only`, { encoding: 'utf-8' });
    const fileList = files.split('\n').filter(Boolean);
    
    const analysis = {
      hasBreakingChanges: false,
      hasNewFeatures: false,
      hasBugFixes: false,
      affectedPackages: new Set(),
      fileTypes: {
        src: 0,
        test: 0,
        docs: 0,
        config: 0
      }
    };
    
    fileList.forEach(file => {
      // 判断影响的包（monorepo）
      if (file.startsWith('packages/')) {
        const pkg = file.split('/')[1];
        analysis.affectedPackages.add(pkg);
      }
      
      // 判断文件类型
      if (file.includes('test') || file.includes('spec')) {
        analysis.fileTypes.test++;
      } else if (file.includes('README') || file.includes('docs/')) {
        analysis.fileTypes.docs++;
      } else if (file.match(/\.(json|yml|yaml|config\.|rc)$/)) {
        analysis.fileTypes.config++;
      } else if (file.match(/\.(js|ts|jsx|tsx)$/)) {
        analysis.fileTypes.src++;
      }
      
      // 检查是否有 breaking changes
      if (file.includes('BREAKING') || file.includes('migration')) {
        analysis.hasBreakingChanges = true;
      }
    });
    
    return analysis;
  } catch (error) {
    console.error('Failed to analyze files:', error);
    return null;
  }
}

/**
 * 生成 changeset 内容
 */
function generateChangesetContent(prTitle, prBody, versionType, changes) {
  // 提取 PR 描述中的关键信息
  const summary = prTitle || 'Update dependencies and fix bugs';
  
  // 生成描述
  let description = '';
  
  if (prBody) {
    // 从 PR body 中提取 "## What" 或 "## Summary" 部分
    const whatMatch = prBody.match(/##\s*(What|Summary|Description)([\s\S]*?)(?=##|$)/i);
    if (whatMatch) {
      description = whatMatch[2].trim();
    } else {
      // 取前几行作为描述
      description = prBody.split('\n').slice(0, 3).join('\n').trim();
    }
  }
  
  if (!description && changes.length > 0) {
    description = changes.slice(0, 5).join('\n');
  }
  
  return `---
"github-workflows": ${versionType}
---

${summary}

${description}
`;
}

/**
 * 创建 changeset 文件
 */
function createChangeset(content) {
  const changesetDir = path.join(process.cwd(), '.changeset');
  
  // 确保 .changeset 目录存在
  if (!fs.existsSync(changesetDir)) {
    fs.mkdirSync(changesetDir, { recursive: true });
  }
  
  // 生成随机文件名
  const adjectives = ['brave', 'calm', 'clever', 'cool', 'eager', 'fair', 'gentle', 'happy', 'kind', 'nice'];
  const animals = ['ant', 'bee', 'cat', 'dog', 'eel', 'fox', 'gnu', 'hen', 'pig', 'rat'];
  const adj = adjectives[Math.floor(Math.random() * adjectives.length)];
  const animal = animals[Math.floor(Math.random() * animals.length)];
  const filename = `${adj}-${animal}-auto.md`;
  
  const filepath = path.join(changesetDir, filename);
  fs.writeFileSync(filepath, content);
  
  console.log(`✅ Created changeset: ${filename}`);
  return filepath;
}

/**
 * 主函数
 */
function main() {
  const args = process.argv.slice(2);
  const prTitle = process.env.PR_TITLE || args[0];
  const prBody = process.env.PR_BODY || args[1];
  const baseBranch = process.env.BASE_BRANCH || 'main';
  
  console.log('🔍 Analyzing PR changes...');
  
  // 分析 commits
  const { versionType, changes } = analyzeCommits(baseBranch);
  console.log(`📊 Suggested version bump: ${versionType}`);
  
  // 分析文件
  const fileAnalysis = analyzeFiles(baseBranch);
  if (fileAnalysis) {
    console.log(`📁 Files changed: ${fileAnalysis.fileTypes.src} source, ${fileAnalysis.fileTypes.test} test`);
    if (fileAnalysis.affectedPackages.size > 0) {
      console.log(`📦 Affected packages: ${Array.from(fileAnalysis.affectedPackages).join(', ')}`);
    }
  }
  
  // 生成 changeset 内容
  const content = generateChangesetContent(prTitle, prBody, versionType, changes);
  
  // 创建文件
  const filepath = createChangeset(content);
  
  // 输出结果供 GitHub Actions 使用
  console.log(`::set-output name=changeset_file::${filepath}`);
  console.log(`::set-output name=version_type::${versionType}`);
  
  return { filepath, versionType };
}

// 如果直接运行
if (require.main === module) {
  main();
}

module.exports = { analyzeCommits, analyzeFiles, generateChangesetContent };