if not Locales then Locales = {} end
Locales['en'] = {
    ['description'] = 'Click on the button to see the animation',
    ['animations'] = 'Animations',
    ['quick_animations'] = 'Quick Animations',

    ['search_placeholder'] = 'Search...',
    ['accept_shared_anim'] = 'Accept',
    ['decline_shared_anim'] = 'Decline',

    ['notification_error'] = 'Error',
    ['no_player_nearby'] = 'No players nearby!',
    ['invite_sent'] = '%s animation invite sent to %s id.',

    ['new_invite'] = 'New Invite!',
    ['invited_animation'] = 'Invited %s animation',
    ['invite_question'] = 'Do u want to accept?',

    ['too_far_away_title'] = 'Animation Position',
    ['too_far_away_text'] = 'You are too far away from the last used location, the ped has been deleted',

    ['settings_header'] = 'SETTINGS',

    ['settings_header_1'] = 'MENU TYPE',
    ['settings_description_1'] = 'Select the menu type you want to use.', 
    ['settings_menu_type_1'] = 'Default',
    ['settings_menu_type_2'] = 'Medium',
    ['settings_menu_type_3'] = 'Minimal',

    ['settings_header_2'] = 'BUTTONS',
    ['settings_description_2'] = 'Choose according to your own preference.',
    ['settings_button_streamer_mode'] = 'Streamer Mode',
    ['settings_button_show_gif'] = 'Show Gifs',
    ['settings_button_white_gif'] = 'White GIFs (Silhouette)',
    
    ['settings_header_theme'] = 'THEME COLOR',
    ['settings_description_theme'] = 'Choose your accent color',
    
    ['settings_header_3'] = 'SEQUENCES',
    ['settings_description_3'] = 'You can create your own sequences by clicking and selecting animations',
    ['select_sequence'] = 'Select Sequence',
    ['seconds'] = ' seconds',

    ['sequence_clear_button'] = 'CLEAR',
    ['sequence_remove_button'] = 'REMOVE',
    ['sequence_save_button'] = 'SAVE',
    
    ['sequence_command'] =  '/sequence',
    
    ['wheel_config_title'] = 'WHEEL CONFIGURATION',
    ['wheel_config_subtitle'] = 'Configure emotes for quick wheel access',
    ['wheel_page_indicator'] = 'PAGE %s / %s',
    ['wheel_clear_page'] = 'CLEAR PAGE',
    ['wheel_delete_page'] = 'DELETE PAGE',
    ['wheel_slots_filled'] = '%s/8 Slots Filled',
    ['wheel_total_emotes'] = '%s/24 Total',
    ['wheel_click_slot'] = 'Click slot to assign',
    ['wheel_select_emote'] = 'Select emote or click again to clear',
    ['wheel_selected_slot'] = 'Selected Slot:',
    ['wheel_current_emote'] = 'Current Emote:',
    ['wheel_browse_emotes'] = 'Browse Emotes',
    ['wheel_clear_slot'] = 'Clear Slot',
    
    ['selection_banner_text'] = 'Select an animation',
    ['selection_banner_cancel'] = 'Cancel',
    
    -- Group Emote
    ['group_header'] = 'GROUP EMOTE',
    ['group_description'] = 'Create a group to sync emotes with nearby players',
    ['group_create'] = 'Create Group',
    ['group_disband'] = 'Disband Group',
    ['group_leave'] = 'Leave Group',
    ['group_members'] = 'Group Members',
    ['group_sync_info'] = 'Click any emote to sync with your group',
    ['group_you'] = 'You',
    ['group_owner'] = 'Owner',
    ['group_no_members'] = 'No members in group',
    ['group_nearby'] = 'Nearby Players',
    ['group_nearby_desc'] = 'Invite players within 10 meters',
    ['group_refresh'] = 'Refresh',
    ['group_no_nearby'] = 'No players nearby',
    ['group_invite_sent_title'] = 'Invite Sent',
    ['group_invite_sent_text'] = 'Group invite sent to %s',
    ['group_invite_received_title'] = 'GROUP INVITE',
    ['group_invite_received_text'] = '%s invited you to join their group',
    ['group_invite_accepted_title'] = 'Invite Accepted',
    ['group_invite_accepted_text'] = '%s joined your group!',
    ['group_invite_declined_title'] = 'Invite Declined',
    ['group_invite_declined_text'] = '%s declined your invite',
    ['group_joined_title'] = 'Group Joined',
    ['group_joined_text'] = 'You joined %s\'s group',
    ['group_accept'] = 'Accept',
    ['group_decline'] = 'Decline',
    ['group_already_invited'] = 'Already invited',
    ['group_kick_member'] = 'Kick',
    ['group_invite_btn'] = 'Invite',
    ['group_created_print'] = '^2[GroupEmote] Group created!',
    ['group_disbanded_print'] = '^3[GroupEmote] Group disbanded',
    ['group_left_print'] = '^3[GroupEmote] Left group',
    ['group_kicked_print'] = '^1[GroupEmote] You were kicked from the group',
    ['group_joined_print'] = '^2[GroupEmote] Joined group!',
    ['group_member_joined_print'] = '^2[GroupEmote] %s joined the group',
    ['group_too_far'] = 'You are too far from the target player!',

    ['ptfx_title'] = 'Effect',
    ['ptfx_prompt'] = 'Press [%s] to activate the effect.',

    ['nearby_no_emote'] = 'Please specify an emote name. Usage: /nearby [emote]',
    ['nearby_emote_not_found'] = 'Emote not found: %s',
    ['nearby_no_shared'] = 'This emote does not support shared animation!',
    ['pointing_weapon_error'] = 'You cannot point while holding a weapon!',
}

local label = 0
function test(tbl)
    if tbl[1] == 1 then
        return true
    end

    if tbl[2] == 4 then
        label = 1
    end

end