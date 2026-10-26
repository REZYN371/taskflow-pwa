import type { Config } from 'tailwindcss';
const config: Config = { content: ['./app/**/*.{js,ts,jsx,tsx,mdx}','./components/**/*.{js,ts,jsx,tsx,mdx}'], theme: { extend: { colors: { ink:'#17211d', muted:'#758078', canvas:'#f5f7f4', brand:'#2f7257', mint:'#e5f2e9', line:'#e6ebe6', amber:'#f4b942' }, boxShadow: { soft:'0 8px 30px rgba(28,55,40,.06)' } } }, plugins: [] };
export default config;
