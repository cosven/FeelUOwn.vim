import os
import subprocess
import sys
import neovim

sys.path.append(os.path.abspath(os.path.dirname(__file__)))
print(os.path.abspath(os.path.dirname(__file__)))

from fuo.model import NUserModel


@neovim.plugin
class Feeluown(object):
    def __init__(self, vim):
        self.vim = vim
        self.user = NUserModel.load()
        self.songs = []
        self.playlists = []

    @neovim.command('Feeluown')
    def feeluown(self):
        self.playlists = self.user.playlists
        self.show_user()

    def load_songs(self, pid):
        pass

    def show_user(self):
        self.show_user_playlists()

    def show_user_playlists(self):
        self.vim.command('echo "feeluown loaded."')
        self.vim.command('split playlists.feeluown')
        self.vim.command('buffer playlists.feeluown')
        self.vim.command('set buftype=nofile')
        self.vim.command('set bufhidden=hide')
        self.vim.command('set nonumber')
        self.vim.command('nnoremap <buffer> <CR> :FeeluownLoadPlaylist<CR>')
        self.vim.current.buffer[:] = [
            str(index) + '. ' + p.name
            for index, p in enumerate(self.playlists)]

    def show_playlist_songs(self, playlist):
        self.songs = playlist.songs
        self.vim.command('echo "feeluown loaded."')
        self.vim.command('vsplit songs.feeluown')
        self.vim.command('buffer songs.feeluown')
        self.vim.command('set buftype=nofile')
        self.vim.command('set bufhidden=hide')
        self.vim.command('set nonumber')
        self.vim.command('nnoremap <buffer> <CR> :FeeluownPlay<CR>')
        self.vim.current.buffer[:] = [
            str(index) + '. ' + song.title + ' - ' + song.artists_name
            for index, song in enumerate(playlist.songs)]

    @neovim.command('FeeluownLoadPlaylist')
    def load_playlist(self):
        self.vim.command('echo "feeluown load playlist"')
        index = int(self.vim.current.line.split('.')[0])
        playlist = self.playlists[index]
        self.show_playlist_songs(playlist)

    @neovim.command('FeeluownPlay')
    def play(self):
        self.vim.command('echo "feeluown play song"')
        index = int(self.vim.current.line.split('.')[0])
        song = self.songs[index]
        self.vim.command('echo "url is %s"' % song.url)
        # os.system('mplayer %s' % song.url)
        subprocess.Popen(['mpg123', song.url])
        self.vim.command('echo "playing?"')
