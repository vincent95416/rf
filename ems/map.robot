*** Settings ***
Resource    ../init.robot
Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

*** Keywords ***
Suite Setup
    New Browser    browser=${browser}    headless=False    slowMo=0
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    New Page    ${url}
    Log    Testing version ${VERSION} in ${ENV} environment

Suite Teardown
    Close Browser

*** Test Cases ***
登入
    [Tags]    high_priority
    [Documentation]    輸入組織ID,帳號密碼並登入
    Wait For Elements State    id=org_number    visible
    Fill Text    id=org_number    ${org}
    Fill Text    id=account    ${acc}
    Fill Text    id=password    ${pw}
    Click    id=loginBtn

建立一個測試用的label並開始widget編輯模式
    [Tags]    high_priority
    [Documentation]    打開widget編輯模式,以利後續測試
    Set Browser Timeout    10s
    Wait For Elements State    id=next_page_url    visible
    Click   id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> id=add_page_btn    visible
    Hover    id=menu_aside
    Wait For Element And Click It    //p[@class='nav_page_text' and text()='QA']
    Wait For Elements State    id=next_page_url    visible
    Wait For Element And Click It    id=next_page_url >>> //span[@data-i18n='index.button.add_page_tag' and text()='新增頁籤']
    Wait For Elements State    id=iframe_device    visible
    Fill Text    id=iframe_device >>> input[id=page_txt]    平面圖A_A
    Sleep    1s
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms
    Sleep    1s
    Wait For Elements State    id=next_page_url    visible

新增平面圖
    [Documentation]    建立平面圖
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=平面圖_btn
    #Click With Options    id=XL_cardType_widgets    force=True
    #現在onclick事件有bug,無法選中XL的平面圖widget,因此改執行下兩行程式碼
    Click With Options    xpath=/html/body/div[3]/div[2]/div[1]/div/div/div[1]/p[2]    delay=100ms
    Get Attribute    id=Map_L_div    class    ==    widget-group widget-donut widget-selected
    Sleep    2s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大平面圖
    Fill Text    id=s_title    小平面圖
    Click With Options    .btn-clear.d-flex.flex-row.align-items-center.f-16-600.c-blue.mt-2.mb-3    delay=100ms
    Wait For Elements State    id=iframe_map >>> css=body    visible
    Upload File By Selector    id=iframe_map >>> input#file2    53W8K9.jpg
    Click With Options    id=iframe_map >>> id=upload_submit    delay=100ms
    Get Text    id=status_msg_content    ==    已上傳
    Get Attribute    id=iframe_map >>> id=nomap_icon    class    ==    icon icon-100 icon-nomap d-none
    Get Text    id=iframe_map >>> id=map_name_show    ==    53W8K9.jpg
    #icon新增
    Wait For Element And Click It    id=iframe_map >>> id=add_widget_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> css=body    visible
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=device_model_select    value    3
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=widget_icon_select    value    single_ao_widget
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Get Attribute    id=iframe_map >>> id=iframe_map_widget >>> id=step2_title    class    ==    path active
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_dev    value    Orange-VTE-9999
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_nodes    value    ${node_id}
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=100ms
    Get Text    id=status_msg_content    ==    已加入
    Sleep    1s
    ${icon1}    Get Element    id=iframe_map >>> css=span[databind='${org}-VTE-9999NODE${node_id}']
    Hover    ${icon1}
    Wait For Elements State    id=iframe_map >>> .map_widget_hover    visible
    ${nowrap1}    Get text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[5]/span[1]
    Should Contain    ${nowrap1}    風速
    Sleep    1s
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已儲存
    Click With Options    id=old_save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已新增
    Sleep    3s

編輯平面圖
    [Documentation]    編輯平面圖
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Scroll To Element    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div[1]/div[1]/div[2]/button
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div[1]/div[1]/div[2]/button    delay=100ms
    Click    id=next_page_url >>> xpath=//span[@data-i18n='widget.edit.map']
    Wait For Elements State    id=iframe_map >>> css=body    visible
    Upload File By Selector    id=iframe_map >>> input#file2    90909.jpg
    Sleep    1s
    Click With Options    id=iframe_map >>> id=upload_submit    delay=100ms
    Sleep    1s
    Get Text    id=status_msg_content    ==    已上傳
    Wait For Elements State    id=iframe_map >>> id=map_name_show    stable
    Get Text    id=iframe_map >>> id=map_name_show    ==    90909.jpg
    #icon處理,刪除、編輯等動作
    Wait For Elements State    id=iframe_map >>> .widget-box    visible
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Edit_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> id=widget_demo_view_area    visible
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Fill Text    id=iframe_map >>> id=iframe_map_widget >>> id=unit    Q
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=100ms
    Get Text    id=status_msg_content    ==    已加入
    Get Text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div/span[2]    ==    Q
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Copy_btn
    Get Text    id=status_msg_content    ==    已複製
    @{box}    Get Elements    id=iframe_map >>> .widget-box
    Length Should Be    ${box}    2
    Click With Options    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[3]    delay=500ms    button=right    force=True
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Del_btn
    @{box_after_del}    Get Elements    id=iframe_map >>> .widget-box
    Length Should Be    ${box_after_del}    1
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=100ms
    Get Text    id=status_msg_content    ==    已儲存
    Sleep    3s