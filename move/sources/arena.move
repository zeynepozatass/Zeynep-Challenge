module challenge::arena;

use challenge::hero::Hero;
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {

    let arena = Arena {
        id:object::new(ctx),
        warrior: hero,
        owner: tx_context::sender(ctx),
    };
    event::emit(ArenaCreated {
            arena_id: object::id(&arena),
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        }
        
    );
    transfer::share_object(arena);
    
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    let Arena {id,warrior, owner} = arena;

    let hero_power = challenge::hero::power(&hero);
    let warrior_power = challenge::hero::power(&warrior);

    if(hero_power>warrior_power){
        let winner_hero_id = object::id(&hero);
        let loser_hero_id = object::id(&warrior);
        
        transfer::public_transfer(hero, tx_context::sender(ctx));
        transfer::public_transfer(warrior, tx_context::sender(ctx));
        event::emit(ArenaCompleted{
            winner_hero_id,
            loser_hero_id,
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });
    }else{
        let winner_hero_id=object::id(&warrior);
        let loser_hero_id=object::id(&hero);

        transfer::public_transfer(warrior, owner);
        transfer::public_transfer(hero, owner);

        event::emit(ArenaCompleted{
            winner_hero_id,
            loser_hero_id,
            timestamp: tx_context::epoch_timestamp_ms(ctx),
        });
    };
    object::delete(id);
    
        
}

