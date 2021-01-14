/// @description 초기화
#macro LEVER_COUNT_DEFAULT 3
#macro LEVER_COUNT_MAX 6

#macro GAME_TAP_COUNT_GENERAL 1000

global.stage = 0

enum DIFFICULTY {
	NONE = -1,
	EASY,
	MEDIUM,
	HARD
}
global.difficult = DIFFICULTY.NONE

alarm[0] = 1
