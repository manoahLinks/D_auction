#[starknet::interface]
trait IDauction<TContractState> {
    fn create_auction(
        ref self: TContractState, _minBidPrice: u256, _startTime: u256, _endTime: u256
    ) -> bool;
    fn reveal_bid(ref self: TContractState, id: u256) -> bool;
    fn settle_bid(ref self: TContractState, id: u256) -> bool;
}

#[starknet::contract]
mod Dauction {
    use super::{IDauction};
    use core::zeroable::Zeroable;
    use starknet::{get_caller_address, ContractAddress};

    #[storage]
    struct Storage {
        totalAuctions: u256,
        activeAuctions: u256,
        minAuctionPeriod: u256,
        bids: LegacyMap::<(u256, ContractAddress), BidAuction>,
        userAuctions: LegacyMap::<ContractAddress, Auction>
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct BidAuction {
        amount: u256
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct Auction {
        id: u256,
        owner: ContractAddress,
        startTime: u256,
        minBidPrice: u256,
        endTime: u256,
        status: bool
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        settle: Settled,
        bidCreated: BidCreated
    }

    #[derive(Drop, starknet::Event)]
    struct Settled {
        id: u256,
        by: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct BidCreated {
        id: u256,
        duration: u256,
        createdBy: ContractAddress
    }

    mod Errors {
        const ZERO_ADDRESS_ERROR: felt252 = 'Address Zero not Allowed';
        const INVALID_BID_AMOUNT: felt252 = 'Amount cant be processed';
        const TIME_ERROR: felt252 = 'Irregular time setting';
        const INSUFFICIENT_AMOUNT: felt252 = 'Balance insufficient';
    }


    // function implementations
    #[external(v0)]
    impl dauction of IDauction<ContractState> {
        // create auction
        fn create_auction(
            ref self: ContractState, _minBidPrice: u256, _startTime: u256, _endTime: u256
        ) -> bool {
            let caller = get_caller_address();
            let _id = self.totalAuctions.read() + 1;

            assert(!caller.is_zero(), Errors::ZERO_ADDRESS_ERROR);

            assert(_endTime > _startTime, Errors::TIME_ERROR);

            assert(_minBidPrice > 0, Errors::INSUFFICIENT_AMOUNT);

            let _auction_instance = Auction {
                id: _id,
                owner: caller,
                startTime: _startTime,
                minBidPrice: _minBidPrice,
                endTime: _endTime,
                status: false
            };

            self.userAuctions.write(caller, _auction_instance);

            self.totalAuctions.write(_id);

            true
        }


        fn reveal_bid(ref self: ContractState, id: u256) -> bool {
            true
        }

        fn settle_bid(ref self: ContractState, id: u256) -> bool {
            true
        }
    }
}
