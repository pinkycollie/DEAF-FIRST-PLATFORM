#!/usr/bin/env node
import { Command } from 'commander';
import { createProject } from './generator.js';
import { listTemplates } from './templates.js';
import chalk from 'chalk';

const program = new Command();

program
  .name('deaf-first-create')
  .description('Generate production-ready DEAF-FIRST SaaS applications')
  .version('1.0.0');

program
  .command('create <project-name>')
  .description('Create a new DEAF-FIRST SaaS project')
  .option('-t, --template <template>', 'Template to use (basic, advanced, enterprise)', 'basic')
  .option('--deafauth', 'Include DeafAUTH integration', true)
  .option('--pinksync', 'Include PinkSync integration', true)
  .option('--fibonrose', 'Include FibonRose integration', true)
  .option('--deaf-ui', 'Include Deaf UI components', true)
  .option('--ai', 'Include AI services integration', false)
  .option('-o, --output <directory>', 'Output directory', '.')
  .action(async (projectName, options) => {
    console.log(chalk.blue.bold('\n🚀 DEAF-FIRST SaaS Generator\n'));
    console.log(chalk.gray(`Creating project: ${chalk.white.bold(projectName)}`));
    console.log(chalk.gray(`Template: ${chalk.white.bold(options.template)}\n`));
    
    try {
      await createProject(projectName, options);
    } catch (error) {
      console.error(chalk.red.bold('\n❌ Failed to create project!'));
      if (error instanceof Error) {
        console.error(chalk.red(error.message));
      } else {
        console.error(chalk.red(String(error)));
      }
      process.exit(1);
    }
  });

program
  .command('templates')
  .description('List available templates')
  .action(() => {
    console.log(chalk.blue.bold('\n📋 Available Templates\n'));
    listTemplates();
  });

program
  .command('info')
  .description('Show information about DEAF-FIRST Platform')
  .action(() => {
    console.log(chalk.blue.bold('\n📚 DEAF-FIRST Platform Information\n'));
    console.log(chalk.white('The DEAF-FIRST Platform is a comprehensive SaaS ecosystem'));
    console.log(chalk.white('designed with accessibility as the primary focus.\n'));
    
    console.log(chalk.yellow('Available Services:'));
    console.log(chalk.gray('  • @deafauth - Accessible authentication service'));
    console.log(chalk.gray('  • @pinksync - Real-time synchronization'));
    console.log(chalk.gray('  • @fibonrose - Mathematical optimization'));
    console.log(chalk.gray('  • Deaf UI - Accessible component library'));
    console.log(chalk.gray('  • AI Services - AI-powered workflows\n'));
    
    console.log(chalk.yellow('Templates:'));
    console.log(chalk.gray('  • basic - Simple SaaS starter'));
    console.log(chalk.gray('  • advanced - Full-featured SaaS with all integrations'));
    console.log(chalk.gray('  • enterprise - Enterprise-grade with multi-tenancy\n'));
  });

program.parse();
