M = {}

M.biome = {
  'biome.json',
  'biome.jsonc',
}
M.biomejs = M.biome

M.deno_fmt = {
  'deno.json',
  'deno.jsonc',
}

M.eslint = {
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
}
M.eslint_d = M.eslint

M.prettierd = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.js',
  'prettier.config.js',
  'prettier.config.mjs',
  'prettier.config.cjs',
}

M.cspell = {
  '.cSpell.json',
  '.cspell.json',
  '.cspell.yaml',
  '.cspell.yml',
  'cSpell.json',
  'cspell.config.cjs',
  'cspell.config.js',
  'cspell.config.json',
  'cspell.config.mjs',
  'cspell.config.toml',
  'cspell.config.yaml',
  'cspell.config.yml',
  'cspell.json',
  'cspell.yaml',
  'cspell.yml',
}

return M
