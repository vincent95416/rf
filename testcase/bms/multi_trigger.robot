*** Settings ***
Resource    ./task.robot
Suite Setup    Initialize Page
Suite Teardown    Close Browser

*** Test Cases ***
登入
    [Documentation]    登入後取得url,token，(待後續整合到每分案例的setup)
    Fill Text    id=account    ${acc}
    Fill Text    id=password    ${pw}
    Click    id=loginBtn
    Wait For Load State    load    30
    Wait For Elements State    .wrapper    visible    15s
    ${current_url}=    Get Url
    ${key_token}    Session Storage Get Item    token
    Log    ${key_token}
    Set Global Variable    ${main_url}    ${current_url}
    Set Global Variable    ${token}    ${key_token}

自動化管理_定時
    [Documentation]    建立定時觸發自動化trigger，並選定Do123與D_04的下控點位
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.auto']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Fill Text    id=automated_name_name    cycle
    Select Options By    id=automated_trigger_condition_condition_type    value    2
    Click With Options    id=automated_trigger_condition_timing_0    delay=100ms
    Select Options By    id=automated_trigger_condition_schedule_timing_0    value    ${trigger_timing_start}
    Select Options By    id=automated_automated_control_device    value    Do_123
    Select Options By    id=automated_automated_control_node    value    Do_04
    Select Options By    id=automated_automated_control_di_node_value    value    0
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms

自動化管理_單一
    [Documentation]    建立多個單一觸發自動化trigger，並選定Do123與D_04的下控點位
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.auto']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Single Mode    single0    0    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Single Mode    single1    1    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Single Mode    single2    2    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Single Mode    single3    3    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}

自動化管理_擇一
    [Documentation]    建立多個擇一觸發自動化trigger，並選定Do123與D_04的下控點位
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.auto']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    0    any0    0    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    0    any1    1    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    0    any2    2    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    0    any3    3    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}

自動化管理_同時
    [Documentation]    建立多個同時觸發自動化trigger，並選定Do123與D_04的下控點位
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.auto']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    1    all0    0    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    1    all1    1    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    1    all2    2    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Apply Trigger Any And All Mode    1    all3    3    ${device_id}    ${node_id}    ${trigger_timing_start}    ${trigger_timing_end}

多條件告警_擇一
    Fill Text    input[placeholder="請輸入名稱"]    ${name}
    Select Options By    xpath=/html/body/div[14]/div/div[2]/div[3]/div/select    value    ${type}
    Click With Options    xpath=//input[@id='automated_trigger_condition_type_1_2']/parent::div[@class='radio']/span    delay=300ms
    Select Options By    xpath=/html/body/div[14]/div/div[2]/div[3]/div[2]/div/div[3]/div/select[1]    value    ${device}
    Select Options By    xpath=/html/body/div[14]/div/div[2]/div[3]/div[2]/div/div[3]/div/select[2]    value    ${node}
    Select Options By    xpath=/html/body/div[14]/div/div[2]/div[3]/div[2]/div/div[4]/select    value    0
    Fill Text    id=automated_trigger_condition_compare_val_1    0
    # 選擇通知頻率
    Click With Options    label[for="automated_trigger_condition_frequency_${frequency}"]    delay=200ms
    Scroll To Element    id=automated_automated_control_device
    Select Options By    id=automated_automated_control_device    value    Do_123
    Select Options By    id=automated_automated_control_node    value    Do_04
    Select Options By    id=automated_automated_control_di_node_value    value    0
    # 點擊啟用週期switch及展開icon
    Click With Options    id=schedule_switch    delay=200ms
    Click With Options    xpath=/html/body/div[21]/div[2]/div[12]/div[2]    delay=200ms
    Sleep    1s
    Get Attribute    id=wf_automated_control    class    ==    collapse show
    Click With Options    id=automated_schedule_schedule_0    delay=100ms
    Select Options By    id=automated_schedule_schedule_time_0_start    value    ${time_start}
    Select Options By    id=automated_schedule_schedule_time_0_end    value    ${time_end}
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms