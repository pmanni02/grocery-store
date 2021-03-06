require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'
require_relative '../lib/order'

Minitest::Reporters.use!

describe "Order Wave 1" do
  describe "#initialize" do
    it "Takes an ID and collection of products" do
      id = 1337
      order = Grocery::Order.new(id, {})

      order.must_respond_to :id
      order.id.must_equal id
      order.id.must_be_kind_of Integer

      order.must_respond_to :products
      order.products.length.must_equal 0
    end
  end

  describe "#total" do
    it "Returns the total from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      sum = products.values.inject(0, :+)
      expected_total = sum + (sum * 0.075).round(2)

      order.total.must_equal expected_total
    end

    it "Returns a total of zero if there are no products" do
      order = Grocery::Order.new(1337, {})

      order.total.must_equal 0
    end
  end

  describe "#add_product" do
    it "Increases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Grocery::Order.new(1337, products)

      order.add_product("salad", 4.25)
      expected_count = before_count + 1
      order.products.count.must_equal expected_count
    end

    it "Is added to the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      order.add_product("sandwich", 4.25)
      order.products.include?("sandwich").must_equal true
    end

    it "Returns false if the product is already present" do
      products = { "banana" => 1.99, "cracker" => 3.00 }

      order = Grocery::Order.new(1337, products)
      before_total = order.total

      result = order.add_product("banana", 4.25)
      after_total = order.total

      result.must_equal false
      before_total.must_equal after_total
    end

    it "Returns true if the product is new" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      result = order.add_product("salad", 4.25)
      result.must_equal true
    end
  end

  describe "#remove_product" do
    it "decreases the number of products" do
      products = {"banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Grocery::Order.new(123, products)

      order.remove_product("banana", 1.99)
      expected_count = before_count - 1
      order.products.count.must_equal expected_count
    end

    it "is removed from collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(123, products)

      order.remove_product("craker", 3.00)
      order.products.include?("craker").must_equal false
    end

    it "returns false if product is not in collection" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(123, products)
      before_total = order.total

      result = order.remove_product("apple", 2.50)
      after_total = order.total

      result.must_equal false
      before_total.must_equal after_total
    end

  end
end

describe "Order Wave 2" do
  describe "Order.all" do
    it "Returns an array of all orders" do
      all_orders = Grocery::Order.all
      expected_length = all_orders.length

      expected_length.must_equal 100
      # Checks that all orders are of class Order
      all_orders.each do |order|
        order.must_be_kind_of Grocery::Order
      end
    end

    it "Returns accurate information about the first order" do
      first_order = Grocery::Order.new(1, {"Slivered Almonds" => 22.88, "Wholewheat flour" => 1.93, "Grape Seed Oil" => 74.9})
      id = first_order.id
      products = first_order.products

      order1_id = Grocery::Order.all[0].id
      order1_products = Grocery::Order.all[0].products

      order1_id.must_equal id
      order1_products.must_equal products
    end

    it "Returns accurate information about the last order" do
      last_order = Grocery::Order.new(100, {"Allspice" => 64.74, "Bran" => 14.72, "UnbleachedFlour" => 80.59})
      id = last_order.id
      products = last_order.products

      order100_id = Grocery::Order.all[99].id
      order100_products = Grocery::Order.all[99].products

      order100_id.must_equal id
      order100_products.must_equal products
    end
  end

  describe "Order.find" do
    it "Can find the first order from the CSV" do
      first_order = Grocery::Order.find(1)
      first_order_id = first_order.id
      first_order_products = first_order.products

      first_order_id.must_equal 1
      first_order_products.must_equal ({"Slivered Almonds" => 22.88, "Wholewheat flour" => 1.93, "Grape Seed Oil" => 74.9})
    end

    it "Can find the last order from the CSV" do
      last_order = Grocery::Order.find(100)
      last_order_id = last_order.id
      last_order_products = last_order.products

      last_order_id.must_equal 100
      last_order_products.must_equal ({"Allspice" => 64.74, "Bran" => 14.72, "UnbleachedFlour" => 80.59})
    end

    it "Raises an error for an order that doesn't exist" do
      no_such_order = Grocery::Order.find(101)
      assert_nil(no_such_order, "ERROR: There is no order with that id")
    end
  end
end
