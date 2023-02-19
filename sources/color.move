module monopad::color {
  use sui::object::{Self, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::transfer;

  struct Color has key, store {
    id: UID,
    red: u32,
    green: u32,
    blue: u32,
    alpha: u8
  }

  public entry fun create(red: u32, green: u32, blue: u32, ctx: &mut TxContext){
    let color = Color {
      id: object::new(ctx),
      red: red,
      green: green,
      blue: blue,
      alpha: 0
    };

    transfer::transfer(color, tx_context::sender(ctx));
  }

  public entry fun copy_color(from_color: &Color, to_color: &mut Color) {
    to_color.red = from_color.red;
    to_color.green = from_color.green;
    to_color.blue = from_color.blue;
    to_color.alpha = from_color.alpha;
  }

  #[test]
  public fun test_copy_colors() {
    use sui::test_scenario;
    use sui::tx_context;
    use std::debug;

    let owner = @0x001;

    let scenario_eval = test_scenario::begin(owner);
    let scenario = &mut scenario_eval;


    let (id_red, id_black) = {
      let ctx = test_scenario::ctx(scenario);

      create(255, 0, 0, ctx);
      let id_red = object::id_from_address(tx_context::last_created_object_id(ctx));

      create(0, 0, 0, ctx);
      let id_black = object::id_from_address(tx_context::last_created_object_id(ctx));

      (id_red, id_black)
    };

    test_scenario::next_tx(scenario, owner);

    {
      let red_color = test_scenario::take_from_sender_by_id<Color>(scenario, id_red);
      let black_color = test_scenario::take_from_sender_by_id<Color>(scenario, id_black);

      assert!(red_color.red == 255, 0);
      assert!(red_color.alpha == 0, 0);

      assert!(black_color.red == 0, 0);
      assert!(black_color.alpha == 0, 0);

      copy_color(&red_color, &mut black_color);

      assert!(black_color.red == 255, 0);
      assert!(black_color.green == 0, 0);
      assert!(black_color.blue == 0, 0);

      // debug::print<&str>("---");
      debug::print(&red_color);
      debug::print(&black_color);

      test_scenario::return_to_sender(scenario, red_color);
      test_scenario::return_to_sender(scenario, black_color);
    };

    test_scenario::end(scenario_eval);
  }

  #[test]
  public fun test_copy_color() {
    use sui::object;
    use sui::test_scenario;
    use sui::tx_context;

    let owner =@0x001;

    let scenario_eval = test_scenario::begin(owner);
    let scenario = &mut scenario_eval;

    let(id_white, id_black ) = {
      let ctx = test_scenario::ctx(scenario);

      // white color
      create(255,255,255, ctx);
      let id_white = object::id_from_address(tx_context::last_created_object_id(ctx));

      // black color
      create(0,0,0, ctx);
      let id_black = object::id_from_address(tx_context::last_created_object_id(ctx));

      (id_white, id_black)
    };

    test_scenario::next_tx(scenario, owner);
    {
      let white_color = test_scenario::take_from_sender_by_id<Color>(scenario, id_white);
      let black_color = test_scenario::take_from_sender_by_id<Color>(scenario, id_black);

      assert!(white_color.red == 255, 0);
      assert!(white_color.green == 255, 0);
      assert!(white_color.blue == 255, 0);
      assert!(white_color.alpha == 0, 0);

      assert!(black_color.red == 0, 0);
      assert!(black_color.green == 0, 0);
      assert!(black_color.blue == 0, 0);
      assert!(black_color.alpha == 0, 0);

      test_scenario::return_to_sender(scenario, white_color);
      test_scenario::return_to_sender(scenario, black_color);
    };

    test_scenario::end(scenario_eval);

  }

}