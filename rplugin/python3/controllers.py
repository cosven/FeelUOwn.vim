import neovim
import threading

from fuocore.models import NUserModel
from fuocore.player import Player


@neovim.plugin
class Feeluown(object):
    def __init__(self, vim):
        self.vim = vim
        self.player = Player()
        self.user = NUserModel.load()
        self.playlists = self.user.playlists

        self.ui_cur_playlist = None

        self.is_running = False

        self.player.position_changed.connect(self.on_player_position_changed)
        self.player.state_changed.connect(self.on_player_state_changed)

    def _t(self):
        while True:
            if self.player._ready_to_exit_flag:
                break
            signal = self.player._signal_queue.get()
            self.vim.async_call(signal.emit)

    @neovim.command('Feeluown')
    def feeluown(self):
        if not self.is_running:
            threading.Thread(target=self._t).start()
            self.is_running = True
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
        self.ui_cur_playlist = playlist
        self.vim.current.buffer[0] = ' | 歌曲名 | 歌手名 | 专辑名 '
        self.vim.current.buffer.append(' | | | ')
        self.vim.current.buffer[2:] = [
            str(index) + ' | ' + song.title + ' | ' + song.artists_name +
            ' | ' + song.album_name
            for index, song in enumerate(playlist.songs)]

    @neovim.command('FeeluownPlayAll')
    def __play_all(self):
        self.player.play_songs(self.ui_cur_playlist.songs)

    @neovim.command('FeeluownPlaySong')
    def __play_song(self):
        index = int(self.vim.current.line.split('|')[0])
        song = self.ui_cur_playlist.songs[index]
        self._play(song)

    @neovim.command('FeeluownPlayNext')
    def __play_next(self):
        self.player.play_next()

    @neovim.command('FeeluownPlayPrevious')
    def __play_last(self):
        self.player.play_last()

    @neovim.command('FeeluownPlayOrPause')
    def toggle(self):
        self.player.toggle()

    @neovim.shutdown_hook
    def on_shutdown(self):
        self.player.shutdown()

    def on_player_position_changed(self):
        self.vim.command('let g:FeeluownPlayerPosition="%s"' %
                         self.player.position)
        self.vim.command('call UpdateStatusline()')

    def on_player_state_changed(self):
        self.vim.command('let g:FeeluownPlayerState="%s"' % self.player.state)
        self.vim.command('call UpdateStatusline()')

    def _play(self, song):
        self.player.play_song(song)
        self.vim.command('let g:FeeluownPlayerSong="%s"' %
                         (song.title + ' - ' + song.artists_name))
        self.vim.command('call UpdateStatusline()')
