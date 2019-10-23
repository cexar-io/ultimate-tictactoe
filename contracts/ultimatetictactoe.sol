pragma solidity 0.5.10;

import "delegatedgas.sol";

contract UltimateTicTacToe is DelegatedGas {
    
    
    /**
     * Constants
     */
    uint constant WAITING = 1;
    uint constant PLAYING = 2;
    uint constant CLOSED = 3;
    uint constant EXPIRATED = 4;

    uint constant EXPIRATION_ROOM_TIME = 20;

    /**
     * Events
     */
    event NewRoom(uint indexed id);


    /**
     * Data Types
     */
    struct Room {
        string name;
        address[2] player;
        bool listable;
        uint valid_until;       // Hasta que bloque es valida
        uint status; 
        uint bet;               // Cuanto hay de apuesta
        
        bytes main_board;       // 9 posiciones
        bytes board;            // 81 Posiciones
        uint valid_board_move;
        
        
        uint turn;              // Player 0 o 1
        uint turn_expiration;    // Hasta que bloque se puede esperar que el jugador juegue
    }

    /**
     * Storage Vars
     */
     
    Room[] room;
 
 
    /**
     * Write Functions
     */
     
    function createRoom (string name, bool listable) external payable {
        Room memory r;
        uint id;
        r.name = name;
        r.player[0] = msg_sender();
        r.listable = listable;
        r.valid_until = block.number + EXPIRATION_ROOM_TIME;
        r.status = WAITING;
        r.bet = msg.value;
        r.main_board = new bytes(9);
        r.board = new bytes(81);
        id = room.push(r);
        
        emit NewRoom(id-1);
    }
    
    function joinRoom (uint id) external payable {
        require (id < room.length, "Index too high");
    
        Room storage r = room[id];
        
        require ( r.status == WAITING && block.number < r.valid_until, "Expiro"); // Change
        
        require ( msg.value == r.bet, "Rata" ); // Change
    
        r.status = PLAYING;    
        r.player[1] = msg_sender();
        r.turn_expiration = block.number + 20; // Change
    }
    
    /*
    function writeboard(uint idx, bytes1 player, bytes storage board ) internal returns (bool) {
        require(board[idx] == 0x00);
        
        board[idx] = player;
        return checkboard(idx/9, board);
    }
    
    function checkboard( uint base, bytes storage board ) internal view returns(bool) {
        uint8[24] memory win_sequences =  [0,1,2,3,4,5,6,7,8,0,3,6,1,4,7,2,5,8,0,4,8,2,4,6];
        uint i;
        
        for (i = 0; i < 24; i = i + 3) 
            if (board[base+win_sequences[i]] == board[base+win_sequences[i+1]] && board[base+win_sequences[i+1]] == board[base+win_sequences[i+2]])
                return true;
        return false;
    }*/
    
    /**
     * View Functions
     */
    function getRoom (uint id) external view returns(address[2] memory player, bytes memory main_board, bytes memory board) {
        player = room[id].player;
        main_board = room[id].main_board;
        board = room[id].board;
    }
    
}

