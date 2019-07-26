#!/usr/bin/env python3

import random

def display_board(board):
    horizon = f'----------------------'
    print(horizon)
    print(f"|7  {board[7]}  |8  {board[8]}  |9  {board[9]}  |")
    print(horizon)
    print(f"|4  {board[4]}  |5  {board[5]}  |6  {board[6]}  |")
    print(horizon)
    print(f"|1  {board[1]}  |2  {board[2]}  |3  {board[3]}  |")
    print(horizon)

def player_input(answer=''):
    while answer not in ['X', 'O']:
        answer = input("Please choose 'X' or 'O': ")
    return answer

def place_marker(board, marker, position):
    board[position] = marker

def win_check(board, mark):
    winning = [(1,2,3), (4,5,6), (7,8,9),
              (1,4,7), (2,5,8), (3,6,9),
              (1,5,9), (3,5,7)]
    for combo in winning:
        a, b, c = combo
        if board[a] == board[b] == board[c] == mark:
            return True
    return False

def choose_first():
    return random.randint(1,2)

def space_check(board, position):
    return board[position] == ' '

def full_board_check(board):
    return ' ' not in board

def player_choice(board):
    choice = int()
    while True:
        choice = int(input("Please pick a number from 1 to 9: "))
        if choice not in (1,2,3,4,5,6,7,8,9):
            print('Try again!')
            continue
        if not space_check(board, choice):
            print("You have to pick a free square!")
            continue
        return choice

def replay():
    answer = input("Would you like to play again? (Y/N): ")
    if answer.lower() in ('y', 'yes'):
        return True
    else:
        return False


while True:
    print("\n\n\nWelcome to Tic Tac Toe!")

    # Initialize new board
    board = ['#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    display_board(board)

    # Decide player order and markers
    print("Let's choose who goes first...")
    current_player = choose_first()
    print(f"The first player is Player {current_player}!")
    current_marker = player_input()

    while True:
        print(f"PLAYER {current_player} [{current_marker}]: ")
        position = player_choice(board)
        place_marker(board, current_marker, position)
        display_board(board)

        if win_check(board, current_marker):
            print(f"\nPlayer {current_player} is the WINNER!")
            break

        if not full_board_check(board):
            # Alternate players
            if current_player == 1:
                current_player = 2
            else:
                current_player = 1
            if current_marker == 'X':
                current_marker = 'O'
            else:
                current_marker = 'X'
            continue
        else:
            print("\nBoard full, it's a TIE!")
            break
    if not replay():
        break
