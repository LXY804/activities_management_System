const sharp = require('sharp')
const path = require('path')
const fs = require('fs')

/**
 * 压缩图片中间件
 * 将图片压缩到合理大小（列表页：800px宽，详情页：1920px宽）
 */
async function compressImage(inputPath, outputPath, options = {}) {
  const { maxWidth = 1920, quality = 85, format = 'jpeg' } = options
  
  try {
    const metadata = await sharp(inputPath).metadata()
    const width = Math.min(metadata.width, maxWidth)
    
    await sharp(inputPath)
      .resize(width, null, {
        withoutEnlargement: true,
        fit: 'inside'
      })
      .jpeg({ quality }) // 或 .webp({ quality })
      .toFile(outputPath)
    
    // 删除原图，使用压缩后的图片
    if (inputPath !== outputPath && fs.existsSync(inputPath)) {
      fs.unlinkSync(inputPath)
    }
    
    return true
  } catch (error) {
    console.error('图片压缩失败:', error)
    return false
  }
}

/**
 * 生成缩略图（用于列表页）
 */
async function generateThumbnail(inputPath, outputPath, width = 400) {
  try {
    await sharp(inputPath)
      .resize(width, null, {
        withoutEnlargement: true,
        fit: 'inside'
      })
      .jpeg({ quality: 80 })
      .toFile(outputPath)
    
    return true
  } catch (error) {
    console.error('生成缩略图失败:', error)
    return false
  }
}

module.exports = { compressImage, generateThumbnail }

