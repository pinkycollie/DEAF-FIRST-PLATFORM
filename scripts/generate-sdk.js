/**
 * SDK Generator Script
 * Generates TypeScript and Python SDKs from OpenAPI specifications
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const SERVICES_DIR = path.join(__dirname, '..', 'services');
const SDK_OUTPUT_DIR = path.join(__dirname, '..', 'sdks');

const SDK_CONFIGS = {
  typescript: {
    generator: 'typescript-axios',
    outputDir: 'typescript',
    additionalProps: {
      npmName: '@mbtq/sdk',
      npmVersion: '1.0.0',
      supportsES6: true,
      withSeparateModelsAndApi: true
    }
  },
  python: {
    generator: 'python',
    outputDir: 'python',
    additionalProps: {
      packageName: 'mbtq_sdk',
      projectName: 'mbtq-sdk',
      packageVersion: '1.0.0'
    }
  }
};

function ensureDirectoryExists(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function generateSDK(service, specPath, language) {
  const config = SDK_CONFIGS[language];
  const outputDir = path.join(SDK_OUTPUT_DIR, config.outputDir, service);
  
  console.log(`\n📦 Generating ${language} SDK for ${service}...`);
  
  ensureDirectoryExists(outputDir);
  
  // Build additional properties string
  const additionalProps = Object.entries(config.additionalProps)
    .map(([key, value]) => `${key}=${value}`)
    .join(',');
  
  try {
    // Use openapi-generator-cli
    const command = [
      'npx',
      '@openapitools/openapi-generator-cli',
      'generate',
      `-i ${specPath}`,
      `-g ${config.generator}`,
      `-o ${outputDir}`,
      `--additional-properties=${additionalProps}`,
      '--skip-validate-spec' // We already validated
    ].join(' ');
    
    execSync(command, { stdio: 'inherit' });
    
    console.log(`   ✅ ${language} SDK generated successfully`);
    console.log(`   📁 Output: ${outputDir}`);
    
    return true;
  } catch (error) {
    console.error(`   ❌ Failed to generate ${language} SDK: ${error.message}`);
    return false;
  }
}

function generateAllSDKs(language) {
  console.log('═══════════════════════════════════════════════════════════');
  console.log(`  Generating ${language.toUpperCase()} SDKs`);
  console.log('═══════════════════════════════════════════════════════════');
  
  const services = fs.readdirSync(SERVICES_DIR)
    .filter(name => {
      const servicePath = path.join(SERVICES_DIR, name);
      return fs.statSync(servicePath).isDirectory();
    });
  
  let successCount = 0;
  
  for (const service of services) {
    const specPath = path.join(SERVICES_DIR, service, 'openapi', 'openapi.yaml');
    
    if (fs.existsSync(specPath)) {
      const success = generateSDK(service, specPath, language);
      if (success) successCount++;
    } else {
      console.log(`\n⚠️  ${service}: No OpenAPI spec found`);
    }
  }
  
  console.log('\n═══════════════════════════════════════════════════════════');
  console.log(`\n📊 Summary:`);
  console.log(`   Services processed: ${services.length}`);
  console.log(`   SDKs generated: ${successCount}`);
  
  if (successCount === services.length) {
    console.log(`\n✅ All ${language} SDKs generated successfully!`);
    console.log(`📁 Output directory: ${path.join(SDK_OUTPUT_DIR, SDK_CONFIGS[language].outputDir)}`);
  } else {
    console.log(`\n⚠️  Some SDKs failed to generate`);
  }
}

// Main execution
const language = process.argv[2];

if (!language || !SDK_CONFIGS[language]) {
  console.error('Usage: node generate-sdk.js [typescript|python]');
  console.error('Available languages:', Object.keys(SDK_CONFIGS).join(', '));
  process.exit(1);
}

console.log('\n🚀 MBTQ Universe SDK Generator\n');

// Ensure SDK output directory exists
ensureDirectoryExists(SDK_OUTPUT_DIR);

generateAllSDKs(language);
