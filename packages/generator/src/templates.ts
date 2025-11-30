import chalk from 'chalk';

export interface Template {
  name: string;
  description: string;
  features: string[];
}

export const templates: Template[] = [
  {
    name: 'basic',
    description: 'Simple SaaS starter with essential features',
    features: [
      'React frontend with Vite',
      'Express backend API',
      'DeafAUTH integration',
      'Deaf UI components',
      'Basic routing',
      'Authentication flow',
    ],
  },
  {
    name: 'advanced',
    description: 'Full-featured SaaS with all integrations',
    features: [
      'Everything in Basic template',
      'PinkSync real-time sync',
      'FibonRose optimization',
      'WebSocket support',
      'Advanced state management',
      'Multi-page application',
      'Dashboard components',
    ],
  },
  {
    name: 'enterprise',
    description: 'Enterprise-grade SaaS with multi-tenancy',
    features: [
      'Everything in Advanced template',
      'AI Services integration',
      'Multi-tenancy support',
      'Role-based access control',
      'Audit logging',
      'Advanced security features',
      'Analytics dashboard',
      'Team management',
    ],
  },
];

export function listTemplates(): void {
  templates.forEach((template, index) => {
    console.log(chalk.white.bold(`${index + 1}. ${template.name}`));
    console.log(chalk.gray(`   ${template.description}`));
    console.log(chalk.gray('   Features:'));
    template.features.forEach((feature) => {
      console.log(chalk.cyan(`     • ${feature}`));
    });
    console.log('');
  });
}

export function getTemplate(name: string): Template | undefined {
  return templates.find((t) => t.name === name);
}
