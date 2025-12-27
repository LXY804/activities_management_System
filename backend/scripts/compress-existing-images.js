const sharp = require('sharp')
const fs = require('fs')
const path = require('path')

async function compressExistingImages() {
  const uploadsDir = path.join(__dirname, '..', 'uploads')
  
  if (!fs.existsSync(uploadsDir)) {
    console.log('❌ uploads 目录不存在')
    return
  }
  
  function getAllImageFiles(dir, fileList = []) {
    const files = fs.readdirSync(dir)
    
    files.forEach(file => {
      const filePath = path.join(dir, file)
      const stat = fs.statSync(filePath)
      
      if (stat.isDirectory()) {
        getAllImageFiles(filePath, fileList)
      } else if (/\.(jpg|jpeg|png)$/i.test(file)) {
        fileList.push(filePath)
      }
    })
    
    return fileList
  }
  
  const files = getAllImageFiles(uploadsDir)
  console.log(`📋 找到 ${files.length} 个图片文件\n`)
  
  let processed = 0
  let saved = 0
  let errors = 0
  
  for (const filePath of files) {
    try {
      const stats = fs.statSync(filePath)
      const originalSize = stats.size
      
      // 小于100KB的图片跳过
      if (originalSize < 100 * 1024) {
        continue
      }
      
      // 如果已经是压缩过的（文件名包含 _compressed 或 _thumb），跳过
      if (filePath.includes('_compressed') || filePath.includes('_thumb')) {
        continue
      }
      
      const tempPath = filePath + '.tmp'
      
      // 压缩图片
      await sharp(filePath)
        .resize(1920, null, { 
          withoutEnlargement: true, 
          fit: 'inside' 
        })
        .jpeg({ quality: 85 })
        .toFile(tempPath)
      
      const newSize = fs.statSync(tempPath).size
      
      if (newSize < originalSize) {
        // 备份原图（可选，如果需要保留原图）
        // const backupPath = filePath + '.bak'
        // fs.copyFileSync(filePath, backupPath)
        
        // 替换原图
        fs.renameSync(tempPath, filePath)
        saved += (originalSize - newSize)
        const savedPercent = ((1 - newSize / originalSize) * 100).toFixed(1)
        console.log(`✅ ${path.basename(filePath)}: ${(originalSize/1024).toFixed(0)}KB -> ${(newSize/1024).toFixed(0)}KB (节省 ${savedPercent}%)`)
        processed++
      } else {
        // 压缩后反而更大，删除临时文件
        fs.unlinkSync(tempPath)
      }
    } catch (error) {
      console.error(`❌ ${path.basename(filePath)}:`, error.message)
      errors++
    }
  }
  
  console.log(`\n📊 处理完成:`)
  console.log(`   - 处理文件: ${processed} 个`)
  console.log(`   - 节省空间: ${(saved/1024/1024).toFixed(2)}MB`)
  console.log(`   - 错误: ${errors} 个`)
}

// 检查sharp是否安装
try {
  require('sharp')
  compressExistingImages().catch(console.error)
} catch (error) {
  console.error('❌ 请先安装 sharp: npm install sharp')
  process.exit(1)
}

