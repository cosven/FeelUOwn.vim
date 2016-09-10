import neovim


@neovim.plugin
class Feeluown(object):
    def __init__(self, vim):
        self.vim = vim

    @neovim.command('feeluown')
    def feeluown(self):
        self.vim.command('echo "feeluown loaded"')
