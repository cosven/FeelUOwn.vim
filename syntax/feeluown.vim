
syntax match FeeluownSongsTableGrid '|'
syntax match FeeluownSongsTableIndex '^\d\+ \+'
syntax match FeeluownSongsTableHeader '歌曲名\|歌手名\|专辑名'

highlight default link FeeluownSongsTableGrid Title
highlight default link FeeluownSongsTableHeader  Search
highlight default link FeeluownSongsTableIndex SpecialKey
