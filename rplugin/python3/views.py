import os
import subprocess
import sys
import neovim

sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from fuocore.models import NUserModel
from fuocore.player import Player


@neovim.plugin
class Feeluown(object):
    def __init__(self, vim):
        self.vim = vim
        self.player = Player()
        self.user = NUserModel.load()
        self.playlists = self.user.playlists
        self.songs = []

    @neovim.command('Feeluown')
    def feeluown(self):
        self.vim.command('call ToggleFeeluownUser()')

    @neovim.command('FeeluownFillUserWin', sync=True)
    def show_user(self):
        '''fill content to user.feeluown buffer

        be sure to goto user.feeluown buffer before this function called
        '''
        self.vim.current.buffer[:] = [
            str(index) + '. ' + p.name
            for index, p in enumerate(self.playlists)]

    @neovim.command('FeeluownLoadPlaylist', sync=True, nargs='*')
    def load_playlist(self, args):
        index = int(args[0].split('.')[0])
        playlist = self.playlists[index]
        self.songs = playlist.songs
        self.vim.current.buffer[0] = ' | 歌曲名 | 歌手名 | 专辑名 '
        self.vim.current.buffer.append(' | | | ')
        self.vim.current.buffer[2:] = [
            str(index) + ' | ' + song.title + ' | ' + song.artists_name +
            ' | ' + song.album_name
            for index, song in enumerate(playlist.songs)]

    @neovim.command('FeeluownPlaySong')
    def play_song(self):
        index = int(self.vim.current.line.split('|')[0])
        song = self.songs[index]
        self.player.play_song(song.url)

    @neovim.command('FeeluownPlayOrPause')
    def toggle(self):
        self.player.toggle()

    @neovim.shutdown_hook
    def on_shutdown(self):
        self.player.destroy()
