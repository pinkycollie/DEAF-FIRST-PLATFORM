/**
 * OpenAPI Specification Validator
 * Validates all OpenAPI specs in the services directory
 */

const fs = require('fs');
const path = require('path');
const yaml = require('yaml');
const SwaggerParser = require('@apidevtools/swagger-parser');

const SERVICES_DIR = path.join(__dirname, '..', 'services');

async function validateOpenAPISpec(serviceName, specPath) {
  try {
    console.log(`\n📋 Validating ${serviceName}...`);
    
    // Parse and validate the spec
    const api = await SwaggerParser.validate(specPath);
    
    // Count endpoints
    const pathCount = Object.keys(api.paths || {}).length;
    let endpointCount = 0;
    
    for (const path in api.paths) {
      const methods = api.paths[path];
      endpointCount += Object.keys(methods).filter(m => 
        ['get', 'post', 'put', 'patch', 'delete'].includes(m)
      ).length;
    }
    
    console.log(`   ✅ Valid OpenAPI ${api.openapi} specification`);
    console.log(`   📊 ${pathCount} paths, ${endpointCount} endpoints`);
    console.log(`   📝 Title: ${api.info.title}`);
    console.log(`   🔢 Version: ${api.info.version}`);
    
    return { valid: true, serviceName, pathCount, endpointCount };
  } catch (error) {
    console.error(`   ❌ Validation failed: ${error.message}`);
    return { valid: false, serviceName, error: error.message };
  }
}

async function validateAllSpecs() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  OpenAPI Specification Validation');
  console.log('═══════════════════════════════════════════════════════════');
  
  const services = fs.readdirSync(SERVICES_DIR)
    .filter(name => {
      const servicePath = path.join(SERVICES_DIR, name);
      return fs.statSync(servicePath).isDirectory();
    });
  
  const results = [];
  
  for (const service of services) {
    const specPath = path.join(SERVICES_DIR, service, 'openapi', 'openapi.yaml');
    
    if (fs.existsSync(specPath)) {
      const result = await validateOpenAPISpec(service, specPath);
      results.push(result);
    } else {
      console.log(`\n⚠️  ${service}: No OpenAPI spec found`);
      results.push({ valid: false, serviceName: service, error: 'Spec file not found' });
    }
  }
  
  // Summary
  console.log('\n═══════════════════════════════════════════════════════════');
  const validCount = results.filter(r => r.valid).length;
  const totalEndpoints = results
    .filter(r => r.valid)
    .reduce((sum, r) => sum + r.endpointCount, 0);
  
  console.log(`\n📊 Summary:`);
  console.log(`   Services validated: ${results.length}`);
  console.log(`   Valid specifications: ${validCount}`);
  console.log(`   Total endpoints: ${totalEndpoints}`);
  
  if (validCount === results.length) {
    console.log('\n✅ All OpenAPI specifications are valid!');
    process.exit(0);
  } else {
    console.log('\n❌ Some specifications have errors');
    process.exit(1);
  }
}

// Run validation
validateAllSpecs().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
