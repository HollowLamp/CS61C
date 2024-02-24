#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t* state, unsigned int snum);
static char next_square(game_state_t* state, unsigned int snum);
static void update_tail(game_state_t* state, unsigned int snum);
static void update_head(game_state_t* state, unsigned int snum);

/* Task 1 */
game_state_t* create_default_state() {
  game_state_t* ret = malloc(sizeof(game_state_t));
  ret->num_rows = 18;
  ret->board = malloc((ret->num_rows) * sizeof(char*));
  for(int i = 0; i < 18; i++){
    ret->board[i] = malloc((21) * sizeof(char));
  if(i == 0 || i == 17){
    strcpy(ret->board[i], "####################");
  } else{
    strcpy(ret->board[i], "#                  #");
  }

  }
  set_board_at(ret, 2, 9, '*');
  ret->num_snakes = 1;
  ret->snakes = malloc(sizeof(snake_t));
  ret->snakes->live = true;
  ret->snakes->head_col = 4;
  ret->snakes->head_row = 2;
  set_board_at(ret, 2, 4, 'D');
  ret->snakes->tail_col = 2;
  ret->snakes->tail_row = 2;
  set_board_at(ret, 2, 2, 'd');
  set_board_at(ret, 2, 3, '>');
  return ret;
}

/* Task 2 */
void free_state(game_state_t* state) {
  free(state->snakes);
  for(int i = 0; i < state->num_rows; i++){
    free(state->board[i]);
  }
  free(state->board);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  for(int i = 0; i < state->num_rows; i++){
    for(int j = 0; state->board[i][j] != '\0'; j++)
      {
        fprintf(fp, "%c", state->board[i][j]);
      }
      fprintf(fp, "\n");
  }
  return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t* state, unsigned int row, unsigned int col) {
  return state->board[row][col];
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  if(c == 'w' || c == 'a' || c == 's' || c == 'd') return true;
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  if(c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x') return true;
  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  if(is_head(c) || is_tail (c) || c == '^' || c == '<' || c == 'v' || c == '>') return true;
  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  if(c == '^') return 'w';
  if(c == '<') return 'a';
  if(c == '>') return 'd';
  if(c == 'v') return 's';
  return ' ';   
} 

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  if(c == 'W') return '^';
  if(c == 'A') return '<';
  if(c == 'D') return '>';
  if(c == 'S') return 'v';
  return ' ';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  if(c == 'v' || c == 's' || c == 'S') return cur_row + 1;
  if(c == '^' || c == 'w' || c == 'W') return cur_row - 1;
  return cur_row; 
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  if(c == '>' || c == 'd' || c == 'D') return cur_col + 1;
  if(c == '<' || c == 'a' || c == 'A') return cur_col - 1; 
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t* state, unsigned int snum) {
  snake_t s = state->snakes[snum];
  int cur_r = s.head_row;
  int cur_c = s.head_col;
  char cur_h = state->board[cur_r][cur_c];
  return state->board[get_next_row(cur_r, cur_h)][get_next_col(cur_c, cur_h)];
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t* state, unsigned int snum) {
  snake_t s = state->snakes[snum];
  int cur_r = s.head_row;
  int cur_c = s.head_col;
  char cur_h = state->board[cur_r][cur_c];
  set_board_at(state, cur_r, cur_c, head_to_body(cur_h));
  set_board_at(state, get_next_row(cur_r, cur_h), get_next_col(cur_c, cur_h), cur_h);
  state->snakes[snum].head_row = get_next_row(cur_r, cur_h);
  state->snakes[snum].head_col = get_next_col(cur_c, cur_h);
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t* state, unsigned int snum) {
  snake_t s = state->snakes[snum];
  int cur_r = s.tail_row;
  int cur_c = s.tail_col;
  char cur_t = state->board[cur_r][cur_c];
  set_board_at(state, cur_r, cur_c, ' ');
  state->snakes[snum].tail_row = get_next_row(cur_r, cur_t);
  state->snakes[snum].tail_col = get_next_col(cur_c, cur_t); 
  char c = body_to_tail(get_board_at(state, state->snakes[snum].tail_row, state->snakes[snum].tail_col)); 
  set_board_at(state, get_next_row(cur_r, cur_t), get_next_col(cur_c, cur_t), c);
}


/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  for(int i = 0; i < state->num_snakes; i++){
    if(next_square(state, i) == '#' || is_snake(next_square(state, i))){
      state->snakes[i].live = false;
      set_board_at(state, state->snakes[i].head_row, state->snakes[i].head_col, 'x');
    } else if(next_square(state, i) == '*'){
      update_head(state, i);
      add_food(state);
    } else{
      update_head(state, i);
      update_tail(state, i);
    }
  }
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  int rowcnt = 0;
  game_state_t* s = malloc(sizeof(game_state_t));
  FILE* fp = fopen(filename, "r");
  char cur;
  while((cur = fgetc(fp)) != EOF){
    if(cur == '\n'){
      rowcnt++;
    }
  }
  int colcnt[rowcnt];
  rewind(fp);
  int line = 0;
  int sofar = 0;
  while((cur = fgetc(fp)) != EOF){
    if(cur != '\n'){
      sofar++;
    }
    else{
      colcnt[line] = sofar;
      line++;
      sofar = 0;
    }
  }
  rewind(fp);
  s->board = malloc(rowcnt * sizeof(char*));
  for(int i = 0; i < rowcnt; i++){
    s->board[i] = malloc((colcnt[i] + 1) * sizeof(char));
    for(int j = 0; j < colcnt[i]; j++){
      s->board[i][j] = fgetc(fp);
    }
    s->board[i][colcnt[i]] = '\0';  // 添加字符串结束符
    fgetc(fp);  // 读取并忽略换行符
  }
  fclose(fp);
  s->num_rows = rowcnt;
  return s;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t* state, unsigned int snum) {
  int tr = state->snakes[snum].tail_row;
  int tc = state->snakes[snum].tail_col;
  int curr = state->snakes[snum].tail_row;
  int curc = state->snakes[snum].tail_col;
  char cur = get_board_at(state, curr, curc);
  while(!is_head(cur)){
    curr = get_next_row(curr, cur);
    curc = get_next_col(curc, cur);
    cur = get_board_at(state, curr, curc);
  }
  state->snakes[snum].head_row = curr;
  state->snakes[snum].head_col = curc;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  int scnt = 0;
  for(int i = 0; i < state->num_rows; i++){
    for(int j = 0; state->board[i][j] != '\0'; j++){
      if(is_tail(get_board_at(state, i, j))){
        scnt++;
      }
    }
  }
  state->num_snakes = scnt;
  state->snakes = malloc(scnt * sizeof(snake_t));
  scnt = 0;
  for(int i = 0; i < state->num_rows; i++){
    for(int j = 0; state->board[i][j] != '\0'; j++){
      if(is_tail(get_board_at(state, i, j))){
        state->snakes[scnt].live = true;
        state->snakes[scnt].tail_row = i;
        state->snakes[scnt].tail_col = j;
        find_head(state, scnt);
        scnt++;
      }
    }
  }
  return state;
}
