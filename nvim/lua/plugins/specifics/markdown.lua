return {
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown', 'mdx' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
  },
  {
    'davidmh/mdx.nvim',
    ft = { 'mdx' },
    event = { 'BufEnter *.mdx' },
  },
}
