module monopad:: pad {
  use sui::object::{Self, UID};
  use sui::transfer;
  use sui::tx_context::{Self, TxContext};

  struct Sword has key, store {
    id: UID,
    magic: u64,
    strength: u64,
  }

  struct Forge has key, store {
    id: UID,
    swords_created: u64,
  }

  fun init(ctx: &mut TxContext) {
    let forge = Forge {
        id: object::new(ctx),
        swords_created: 0,
    };
    // transfer the forge object to the module/package publisher
    transfer::transfer(forge, tx_context::sender(ctx));
  }

    // Part 4: accessors required to read the struct attributes
  public fun magic(self: &Sword): u64 {
      self.magic
  }

  public fun strength(self: &Sword): u64 {
      self.strength
  }

  public fun swords_created(self: &Forge): u64 {
      self.swords_created
  }

  public entry fun sword_create(magic: u64, strength: u64, recipient: address, ctx: &mut TxContext) {
    use sui::transfer;

    let sword = Sword {
      magic: magic,
      strength: strength,
      id: object::new(ctx)
    };

    transfer::transfer(sword, recipient);
  }

  public entry fun sword_transfer(sword: Sword, recipient: address, _ctx: &mut TxContext){
    use sui::transfer;

    transfer::transfer(sword, recipient)
  }

  #[test]
  public fun test_sword_create() {
      use sui::transfer;
      use sui::tx_context;

      // create a dummy TxContext for testing
      let ctx = tx_context::dummy();

      // create a sword
      let sword = Sword {
          id: object::new(&mut ctx),
          magic: 42,
          strength: 7,
      };

      // check if accessor functions return correct values
      assert!(magic(&sword) == 42, 1);
      assert!(strength(&sword) == 7, 1);

      // transfer resource to a dummy address
      let dummy_address = @0xCAFE;
      transfer::transfer(sword, dummy_address);
  }

  #[test]
  public fun test_sword_transactions() {
    use sui::test_scenario;

    let admin = @0xBEBEBE;
    let initial_owner = @0xCAFE;
    let final_owner = @0xFACE;

    // 1. emulate module init by admin
    let scenario_eval = test_scenario::begin(admin);
    let scenario = &mut scenario_eval;

    {
      init(test_scenario::ctx(scenario));
    };

    // 2. tx exec by admin to create the sword
    test_scenario::next_tx(scenario, admin);
    {
      // create the sword and transfer it to initial_owner
      sword_create(42, 7, initial_owner, test_scenario::ctx(scenario));
    };

    // 3. tx exec by initial sword owner
    test_scenario::next_tx(scenario, initial_owner);
    {
      // extract the sword owned by the initial owner
      let sword = test_scenario::take_from_sender<Sword>(scenario);

      // transfer the sword to the final owner
      sword_transfer(sword, final_owner, test_scenario::ctx(scenario));
    };

    // 4. tx exec by the final owner
    test_scenario::next_tx(scenario, final_owner);
    {
      // extract the sword owned by the final owner
      let sword = test_scenario::take_from_sender<Sword>(scenario);

      assert!(magic(&sword) == 42u64, 1);
      assert!(strength(&sword) == 7u64, 1);

      test_scenario::return_to_sender(scenario, sword);

    };

    test_scenario::end(scenario_eval);

  }
}