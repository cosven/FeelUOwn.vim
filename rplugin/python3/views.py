import os
import subprocess
import sys
import neovim

sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from fuo.model import NUserModel


@neovim.plugin
class Feeluown(object):
    def __init__(self, vim):
        self.vim = vim
        self.user = NUserModel.load()
        self.playlists = self.user.playlists
        self.songs = []

    @neovim.command('Feeluown')
    def feeluown(self):
        self.show_user()

    @neovim.command('FeeluownShowUser')
    def show_user(self):
        self.show_user_playlists()

    def show_user_playlists(self):
        self.vim.command('vsplit user.feeluown')
        self.vim.command('buffer user.feeluown')
        self.vim.command('nnoremap <buffer> <CR> :FeeluownLoadPlaylist<CR>')
        self.vim.current.buffer[:] = [
            str(index) + '. ' + p.name
            for index, p in enumerate(self.playlists)]
        self.vim.command('vertical resize 40')
        self.vim.command('setlocal nonumber nomodifiable buftype=nofile '
                         'bufhidden=wipe readonly nobuflisted noswapfile '
                         'winfixwidth')

    def show_playlist_songs(self, playlist):
        self.songs = playlist.songs
        self.vim.command('vsplit songs.feeluown')
        self.vim.command('buffer songs.feeluown')
        self.vim.command('nnoremap <buffer> <CR> :FeeluownPlay<CR>')
        self.vim.current.buffer[0] = ' | 歌曲名 | 歌手名 | 专辑名 '
        self.vim.current.buffer[1:] = [
            str(index) + ' | ' + song.title + ' | ' + song.artists_name +
            ' | ' + song.album_name
            for index, song in enumerate(playlist.songs)]
        self.vim.command('Tab /|')
        self.vim.command('setlocal nonumber nomodifiable buftype=nofile '
                         'bufhidden=wipe readonly nobuflisted noswapfile')

    @neovim.command('FeeluownLoadPlaylist')
    def load_playlist(self):
        if self.vim.current.buffer.name.split('/')[-1] != 'user.feeluown':
            self.vim.command('echo "current buffer is not user.feeluown"')
            return 0

        self.vim.command('echo "feeluown load playlist"')
        index = int(self.vim.current.line.split('.')[0])
        playlist = self.playlists[index]
        self.show_playlist_songs(playlist)

    @neovim.command('FeeluownPlay')
    def play(self):
        if self.vim.current.buffer.name.split('/')[-1] != 'songs.feeluown':
            self.vim.command('echo "current buffer is not songs.feeluown"')
            return 0

        self.vim.command('echo "feeluown play song"')
        index = int(self.vim.current.line.split('|')[0])
        song = self.songs[index]
        self.vim.command('echo "url is %s"' % song.url)
        subprocess.Popen(['mpg123', song.url])
        self.vim.command('echo "playing?"')
