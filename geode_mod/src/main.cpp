
#include <Geode/modify/MenuLayer.hpp>
#include <Geode/Geode.hpp>

#include "lib.rs.h"

using namespace geode::prelude;

SharedStruct cpp_get_shared() { return SharedStruct{.bar = 42}; }

// clang-format off
class $modify(MyMenuLayer, MenuLayer) {
    bool init() {
        if (!MenuLayer::init()) {
            return false;
        }

        auto myButton = CCMenuItemSpriteExtra::create(
            CCSprite::createWithSpriteFrameName("GJ_likeBtn_001.png"), 
            this,
            menu_selector(MyMenuLayer::onMyButton)
        );

        auto menu = this->getChildByID("bottom-menu");
        menu->addChild(myButton);

        myButton->setID("my-button"_spr);

        menu->updateLayout();

        return true;
    }

    void onMyButton(CCObject *) {
        auto rustStruct = rust_get_rust_struct();
        auto rustStructFoo = rust_get_rust_struct_foo(std::move(rustStruct));

        geode::log::info("Got rust struct: `foo`: {}", rustStructFoo);

        rust_test_cpp_get_shared();
    }
};
// clang-format on
