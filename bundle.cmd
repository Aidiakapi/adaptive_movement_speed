@SET MOD_NAME=adaptive_movement_speed
@SET /P MOD_VERSION=Version number: 
@SET MOD_IDENTIFIER=%MOD_NAME%_%MOD_VERSION%

@IF EXIST "%MOD_IDENTIFIER%.zip" ( DEL %MOD_IDENTIFIER%.zip )
@7za a -tzip %MOD_IDENTIFIER%.zip src/*
@7za rn %MOD_IDENTIFIER%.zip src %MOD_IDENTIFIER%