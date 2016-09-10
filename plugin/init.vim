" feeluown.vim
" -------------
"
" songs buffer name: songs.feeluown
" playlists buffer name: playlists.feeluown
"
let s:songsBufferName = "songs.feeluown" 


filetype plugin on
au! BufRead,BufNewFile *.feeluown set filetype=feeluown

func! InitVimOptions(...)
    echo "feeluown: init vim options"
    setlocal noswapfile
    normal! gg
endfunc

func! SongsBufferExists()
    if bufwinnr(s:songsBufferName) > 0
        echo "feeluown: songs buffers already exists."
        return 1
    endif
    return 0
endfunc

func! CreateSongsBuffer(...)
    if SongsBufferExists() > 0
        bwipeout s:songsBufferName
    endif
endfunc

autocmd Filetype feeluown call InitVimOptions()
" call CreateSongsBuffer()
