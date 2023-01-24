local Translations = {
    error = {
        something_went_wrong = 'Something went wrong!',
        you_need_item_to_do_that = 'You need a %{item1} and %{item2} to do that!',
        only_farmers_can_plant_seeds = 'Only farmers can plant seeds!',
        you_are_not_in_a_farming_zone = 'You are not in a farming zone!',
        you_may_only_plant_seeds_here = 'You may only plant %{zonename} seeds here!',
        too_close_to_another_plant = 'Too close to another plant!',
        you_already_have_plants_down = 'You already have %{MaxPlantCount} plants down',
    },
    success = {
        you_distroyed_the_plant = 'you distroyed the plant',
        you_harvest_label =  'You harvest %{amount} %{label}',
    },
    primary = {
        you_have_entered_farm_zone = 'You have entered a farm zone!',
        you_have_entered_farm_zone_zonename = 'You have entered a %{zonename} farm zone!',
        you_may_only_plant_seeds_here = 'You may only plant %{zonename} seeds here!',
    },
    menu = {
        open = 'Open ',
    },
    commands = {
        var = 'text goes here',
    },
    progressbar = {
        destroying_the_plants = 'Destroying the plants...',
        harvesting_plants = 'Harvesting the plants...',
        watering_the_plants = 'Watering the plants...',
        fertilising_the_plants = 'Fertilising the plants...',
        planting_seeds = 'Planting %{planttype} seeds...',
    },
    blip = {
        farming_zone = 'Farming Zone',
    },
    text = {
        thirst_hunger = 'Thirst: %{thirst} % - Hunger: %{hunger} %',
        growth_quality = 'Growth: %{growth} % -  Quality: %{quality} %',
        destroy_plant = 'Destroy Plant [G]',
        water_feed = 'Water [G] : Feed [J]',
        quality = '[Quality: ${quality}]',
        harvest = 'Harvest [E]',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
