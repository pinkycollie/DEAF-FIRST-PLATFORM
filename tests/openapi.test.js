/**
 * OpenAPI Specification Tests
 * Integration tests to validate all OpenAPI specs
 */

const fs = require('fs');
const path = require('path');
const yaml = require('yaml');

const SERVICES_DIR = path.join(__dirname, '..', 'services');

describe('OpenAPI Specifications', () => {
  const services = ['deafauth', 'pinksync', 'fibonrose', 'magicians', 'dao'];
  
  services.forEach(service => {
    describe(`${service} OpenAPI Spec`, () => {
      let spec;
      
      beforeAll(() => {
        const specPath = path.join(SERVICES_DIR, service, 'openapi', 'openapi.yaml');
        const content = fs.readFileSync(specPath, 'utf8');
        spec = yaml.parse(content);
      });
      
      it('should have valid OpenAPI version', () => {
        expect(spec.openapi).toBeDefined();
        expect(spec.openapi).toMatch(/^3\.\d+\.\d+$/);
      });
      
      it('should have required info fields', () => {
        expect(spec.info).toBeDefined();
        expect(spec.info.title).toBeDefined();
        expect(spec.info.version).toBeDefined();
        expect(spec.info.description).toBeDefined();
      });
      
      it('should have servers defined', () => {
        expect(spec.servers).toBeDefined();
        expect(Array.isArray(spec.servers)).toBe(true);
        expect(spec.servers.length).toBeGreaterThan(0);
        expect(spec.servers[0].url).toBeDefined();
      });
      
      it('should have security scheme defined', () => {
        expect(spec.components).toBeDefined();
        expect(spec.components.securitySchemes).toBeDefined();
        expect(spec.components.securitySchemes.DeafAuthToken).toBeDefined();
      });
      
      it('should have paths defined', () => {
        expect(spec.paths).toBeDefined();
        expect(Object.keys(spec.paths).length).toBeGreaterThan(0);
      });
      
      it('should have valid response descriptions', () => {
        Object.keys(spec.paths).forEach(path => {
          Object.keys(spec.paths[path]).forEach(method => {
            if (['get', 'post', 'put', 'patch', 'delete'].includes(method)) {
              const operation = spec.paths[path][method];
              expect(operation.responses).toBeDefined();
              
              Object.keys(operation.responses).forEach(statusCode => {
                const response = operation.responses[statusCode];
                expect(response.description).toBeDefined();
                expect(response.description.length).toBeGreaterThan(0);
              });
            }
          });
        });
      });
      
      it('should have consistent base URL pattern', () => {
        const baseUrl = spec.servers[0].url;
        expect(baseUrl).toContain('api.mbtquniverse.com');
      });
    });
  });
  
  describe('Cross-service consistency', () => {
    it('should use unified security scheme across all services', () => {
      services.forEach(service => {
        const specPath = path.join(SERVICES_DIR, service, 'openapi', 'openapi.yaml');
        const content = fs.readFileSync(specPath, 'utf8');
        const spec = yaml.parse(content);
        
        expect(spec.components.securitySchemes.DeafAuthToken).toBeDefined();
        expect(spec.components.securitySchemes.DeafAuthToken.type).toBe('http');
        expect(spec.components.securitySchemes.DeafAuthToken.scheme).toBe('bearer');
      });
    });
    
    it('should have consistent OpenAPI version', () => {
      const versions = new Set();
      
      services.forEach(service => {
        const specPath = path.join(SERVICES_DIR, service, 'openapi', 'openapi.yaml');
        const content = fs.readFileSync(specPath, 'utf8');
        const spec = yaml.parse(content);
        versions.add(spec.openapi);
      });
      
      expect(versions.size).toBe(1);
      expect(Array.from(versions)[0]).toBe('3.1.0');
    });
  });
});
