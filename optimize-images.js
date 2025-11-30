/**
 * Script de Otimização de Imagens para Migração
 * Cake & Cia - Next.js Migration
 * 
 * Uso: node optimize-images.js
 * 
 * Requer: npm install sharp
 */

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const config = {
  input: './edson/images',
  output: './optimized-images',
  productImages: {
    width: 800,
    height: 1200,
    quality: 85,
    format: 'webp'
  },
  logoImages: {
    quality: 90,
    format: 'png'
  }
};

const productFiles = [
  { input: '03.jpg', output: 'cupcake-chocolate.webp', name: 'Chocolate' },
  { input: '04.jpg', output: 'cupcake-morango.webp', name: 'Morango' },
  { input: '11.jpg', output: 'cupcake-baunilha.webp', name: 'Baunilha' },
  { input: '15.jpg', output: 'cupcake-caramelo.webp', name: 'Caramelo' },
  { input: '16.jpg', output: 'cupcake-doce-leite.webp', name: 'Doce de Leite' }
];

const logoFiles = [
  { input: 'logo.png', output: 'logo.png', name: 'Logo Principal' },
  { input: '14.png', output: 'logo-alt.png', name: 'Logo Alternativo' },
  { input: 'qrcode.png', output: 'qrcode-pix.png', name: 'QR Code PIX' }
];

async function createOutputDir() {
  const dirs = [
    config.output,
    path.join(config.output, 'products'),
    path.join(config.output, 'logos')
  ];
  
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }
}

async function getFileSize(filePath) {
  const stats = fs.statSync(filePath);
  return (stats.size / 1024).toFixed(2); // KB
}

async function optimizeProductImages() {
  console.log('\n🍰 Otimizando imagens de produtos...\n');
  
  let totalOriginal = 0;
  let totalOptimized = 0;
  
  for (const file of productFiles) {
    const inputPath = path.join(config.input, file.input);
    const outputPath = path.join(config.output, 'products', file.output);
    
    try {
      const originalSize = await getFileSize(inputPath);
      totalOriginal += parseFloat(originalSize);
      
      await sharp(inputPath)
        .resize(config.productImages.width, config.productImages.height, {
          fit: 'cover',
          position: 'center'
        })
        .webp({ quality: config.productImages.quality })
        .toFile(outputPath);
      
      const optimizedSize = await getFileSize(outputPath);
      totalOptimized += parseFloat(optimizedSize);
      
      const savings = ((1 - optimizedSize / originalSize) * 100).toFixed(1);
      
      console.log(`✅ ${file.name}`);
      console.log(`   Original: ${originalSize} KB`);
      console.log(`   Otimizado: ${optimizedSize} KB`);
      console.log(`   Economia: ${savings}%\n`);
    } catch (error) {
      console.error(`❌ Erro ao processar ${file.name}:`, error.message);
    }
  }
  
  const totalSavings = ((1 - totalOptimized / totalOriginal) * 100).toFixed(1);
  console.log(`📊 Total Produtos:`);
  console.log(`   Original: ${totalOriginal.toFixed(2)} KB`);
  console.log(`   Otimizado: ${totalOptimized.toFixed(2)} KB`);
  console.log(`   Economia: ${totalSavings}%\n`);
}

async function optimizeLogoImages() {
  console.log('🎨 Otimizando logos...\n');
  
  for (const file of logoFiles) {
    const inputPath = path.join(config.input, file.input);
    const outputPath = path.join(config.output, 'logos', file.output);
    
    try {
      const originalSize = await getFileSize(inputPath);
      
      await sharp(inputPath)
        .png({ quality: config.logoImages.quality, compressionLevel: 9 })
        .toFile(outputPath);
      
      const optimizedSize = await getFileSize(outputPath);
      const savings = ((1 - optimizedSize / originalSize) * 100).toFixed(1);
      
      console.log(`✅ ${file.name}`);
      console.log(`   ${originalSize} KB → ${optimizedSize} KB (${savings}% economia)\n`);
    } catch (error) {
      console.error(`❌ Erro ao processar ${file.name}:`, error.message);
    }
  }
}

async function generateManifest() {
  const manifest = {
    generated_at: new Date().toISOString(),
    total_files_optimized: productFiles.length + logoFiles.length,
    products: productFiles.map(f => ({
      original: f.input,
      optimized: `products/${f.output}`,
      name: f.name
    })),
    logos: logoFiles.map(f => ({
      original: f.input,
      optimized: `logos/${f.output}`,
      name: f.name
    })),
    next_js_usage: {
      example: "import Image from 'next/image'\n\n<Image \n  src=\"/images/products/cupcake-chocolate.webp\"\n  alt=\"Cupcake de Chocolate\"\n  width={800}\n  height={1200}\n  quality={85}\n  placeholder=\"blur\"\n/>"
    }
  };
  
  fs.writeFileSync(
    path.join(config.output, 'optimization-manifest.json'),
    JSON.stringify(manifest, null, 2)
  );
  
  console.log('📄 Manifesto criado: optimization-manifest.json\n');
}

async function main() {
  console.log('\n🚀 Iniciando otimização de imagens para Cake & Cia\n');
  console.log('='.repeat(60));
  
  try {
    await createOutputDir();
    await optimizeProductImages();
    await optimizeLogoImages();
    await generateManifest();
    
    console.log('='.repeat(60));
    console.log('\n✅ Otimização concluída com sucesso!');
    console.log(`\n📁 Imagens otimizadas em: ${config.output}/`);
    console.log('\n💡 Próximos passos:');
    console.log('   1. Copiar pasta optimized-images/products para public/images/products');
    console.log('   2. Copiar pasta optimized-images/logos para public/images');
    console.log('   3. Usar Next.js Image component para servir as imagens');
    console.log('   4. Considerar upload para Cloudinary para melhor performance\n');
  } catch (error) {
    console.error('\n❌ Erro durante otimização:', error);
    process.exit(1);
  }
}

main();
