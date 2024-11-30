import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'cmdlang',
  tagline: 'Declarative Command-line Parsing for OCaml',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://mbarbin.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/cmdlang/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'mbarbin', // Usually your GitHub org/user name.
  projectName: 'cmdlang', // Usually your repo name.

  trailingSlash: true,

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: 'https://github.com/mbarbin/cmdlang/tree/main/doc/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl: 'https://github.com/mbarbin/cmdlang/tree/main/doc/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  markdown: {
    mermaid: true,
  },

  themes: ['@docusaurus/theme-mermaid'],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/cmdlang.png',
    navbar: {
      hideOnScroll: true,
      title: 'cmdlang',
      logo: {
        alt: 'Site Logo',
        src: 'img/cmdlang.png',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialsSidebar',
          position: 'left',
          label: 'Tutorials',
        },
        {
          type: 'docSidebar',
          sidebarId: 'guidesSidebar',
          position: 'left',
          label: 'Guides',
        },
        {
          type: 'docSidebar',
          sidebarId: 'referenceSidebar',
          position: 'left',
          label: 'Reference',
        },
        {
          type: 'docSidebar',
          sidebarId: 'explanationSidebar',
          position: 'left',
          label: 'Explanation',
        },
        { to: '/blog/', label: 'Blog', position: 'right' },
        {
          href: 'https://github.com/mbarbin/cmdlang',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    docs: {
      sidebar: {
        hideable: true,
        autoCollapseCategories: true,
      },
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Tutorials',
              to: '/docs/tutorials/getting-started/',
            },
            {
              label: 'Guides',
              to: '/docs/guides/usage-styles/',
            },
            {
              label: 'Reference',
              to: '/docs/reference/odoc/',
            },
            {
              label: 'Explanation',
              to: '/docs/explanation/',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Blog',
              to: '/blog',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/mbarbin/cmdlang',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Mathieu Barbin. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'diff', 'json', 'ocaml'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
