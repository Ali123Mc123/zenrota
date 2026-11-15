if not Locales then Locales = {} end
Locales['ko'] = {
    ['description'] = '애니메이션을 보려면 버튼을 클릭하세요',
    ['animations'] = '애니메이션',
    ['quick_animations'] = '빠른 애니메이션',
    
    ['search_placeholder'] = '검색...',
    ['accept_shared_anim'] = '수락',
    ['decline_shared_anim'] = '거절',
    
    ['notification_error'] = '오류',
    ['no_player_nearby'] = '근처에 플레이어가 없습니다!',
    ['invite_sent'] = '%s 애니메이션 초대가 %s ID에게 전송되었습니다.',
    
    ['new_invite'] = '새 초대!',
    ['invited_animation'] = '%s 애니메이션 초대됨',
    ['invite_question'] = '수락하시겠습니까?',
    
    ['too_far_away_title'] = '애니메이션 위치',
    ['too_far_away_text'] = '마지막 사용 위치에서 너무 멀리 떨어져 있습니다. 페드가 삭제되었습니다.',
    
    ['settings_header'] = '설정',
    
    ['settings_header_1'] = '메뉴 유형',
    ['settings_description_1'] = '사용할 메뉴 유형을 선택하세요.',
    ['settings_menu_type_1'] = '기본',
    ['settings_menu_type_2'] = '중간',
    ['settings_menu_type_3'] = '최소',
    
    ['settings_header_2'] = '버튼',
    ['settings_description_2'] = '개인 취향에 맞게 선택하세요.',
    ['settings_button_streamer_mode'] = '스트리머 모드',
    ['settings_button_show_gif'] = 'GIF 표시',
    ['settings_button_white_gif'] = '흰색 GIF (실루엣)',
    
    ['settings_header_theme'] = '테마 색상',
    ['settings_description_theme'] = '강조 색상을 선택하세요',
    
    ['settings_header_3'] = '시퀀스',
    ['settings_description_3'] = '애니메이션을 클릭하고 선택하여 자신만의 시퀀스를 만들 수 있습니다.',
    ['select_sequence'] = '시퀀스 선택',
    ['seconds'] = '초',
    
    ['sequence_clear_button'] = '지우기',
    ['sequence_remove_button'] = '제거',
    ['sequence_save_button'] = '저장',
    
    ['sequence_command'] = '/sequence',
    
    ['wheel_config_title'] = '휠 구성',
    ['wheel_config_subtitle'] = '빠른 휠 액세스를 위한 이모트 구성',
    ['wheel_page_indicator'] = '페이지 %s / %s',
    ['wheel_clear_page'] = '페이지 지우기',
    ['wheel_delete_page'] = '페이지 삭제',
    ['wheel_slots_filled'] = '%s/8 슬롯 채움',
    ['wheel_total_emotes'] = '%s/24 전체',
    ['wheel_click_slot'] = '할당하려면 슬롯을 클릭하세요',
    ['wheel_select_emote'] = '이모트를 선택하거나 다시 클릭하여 지우기',
    ['wheel_selected_slot'] = '선택된 슬롯:',
    ['wheel_current_emote'] = '현재 이모트:',
    ['wheel_browse_emotes'] = '이모트 찾아보기',
    ['wheel_clear_slot'] = '슬롯 지우기',
    
    ['selection_banner_text'] = '애니메이션 선택',
    ['selection_banner_cancel'] = '취소',
    
    -- Group Emote
    ['group_header'] = '그룹 이모트',
    ['group_description'] = '근처 플레이어와 이모트를 동기화하려면 그룹을 만드세요',
    ['group_create'] = '그룹 만들기',
    ['group_disband'] = '그룹 해산',
    ['group_leave'] = '그룹 나가기',
    ['group_members'] = '그룹 멤버',
    ['group_sync_info'] = '그룹과 동기화하려면 이모트를 클릭하세요',
    ['group_you'] = '나',
    ['group_owner'] = '소유자',
    ['group_no_members'] = '그룹에 멤버가 없습니다',
    ['group_nearby'] = '근처 플레이어',
    ['group_nearby_desc'] = '10미터 이내의 플레이어를 초대하세요',
    ['group_refresh'] = '새로고침',
    ['group_no_nearby'] = '근처에 플레이어가 없습니다',
    ['group_invite_sent_title'] = '초대 전송됨',
    ['group_invite_sent_text'] = '%s에게 그룹 초대를 보냈습니다',
    ['group_invite_received_title'] = '그룹 초대',
    ['group_invite_received_text'] = '%s님이 그룹에 초대했습니다',
    ['group_invite_accepted_title'] = '초대 수락됨',
    ['group_invite_accepted_text'] = '%s님이 그룹에 참여했습니다!',
    ['group_invite_declined_title'] = '초대 거절됨',
    ['group_invite_declined_text'] = '%s님이 초대를 거절했습니다',
    ['group_joined_title'] = '그룹 참여됨',
    ['group_joined_text'] = '%s님의 그룹에 참여했습니다',
    ['group_accept'] = '수락',
    ['group_decline'] = '거절',
    ['group_already_invited'] = '이미 초대됨',
    ['group_kick_member'] = '추방',
    ['group_invite_btn'] = '초대',
    ['group_created_print'] = '^2[GroupEmote] 그룹이 생성되었습니다!',
    ['group_disbanded_print'] = '^3[GroupEmote] 그룹이 해산되었습니다',
    ['group_left_print'] = '^3[GroupEmote] 그룹에서 나갔습니다',
    ['group_kicked_print'] = '^1[GroupEmote] 그룹에서 추방되었습니다',
    ['group_joined_print'] = '^2[GroupEmote] 그룹에 참여했습니다!',
    ['group_member_joined_print'] = '^2[GroupEmote] %s님이 그룹에 참여했습니다',
    ['group_too_far'] = '대상 플레이어에게서 너무 멀리 떨어져 있습니다!',

    ['nearby_no_emote'] = '이모트 이름을 지정해주세요. 사용법: /nearby [emote]',
    ['nearby_emote_not_found'] = '이모트를 찾을 수 없습니다: %s',
    ['nearby_no_shared'] = '이 이모트는 공유 애니메이션을 지원하지 않습니다!',
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