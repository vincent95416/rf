*** Settings ***
Resource    ./task.robot
Suite Setup    Continuous page

*** Test Cases ***
widget編輯模式
    [Documentation]    打開widget編輯模式,以利後續測試
    Wait For Load State    load    30s
    Wait For Elements State    css=body    visible
    Wait For Element And Click It    id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s

新增標籤
    [Tags]    label
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    //p[contains(text(), '測試')]
    Wait For Element And Click It    id=next_page_url >>> //span[@data-i18n='index.button.add_page_tag' and text()='新增頁籤']
    Wait For Elements State    id=iframe_device >>> css=body    visible
    Fill Text    id=iframe_device >>> input[id=page_txt]    robot1
    Sleep    1s
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms

標籤變更順序
    [Tags]    label
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Wait For Elements State    id=next_page_url >>> id=btn_area    visible
    Sleep    1s
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot1']
    Mouse Button    down
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='${init_label}']    -60
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='${init_label}']    0    5
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='${init_label}']    0    -10
    Mouse Button    up
    Get Text    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/p    ==    robot1

編輯,刪除標籤
    [Documentation]    label
    Handle Future Dialogs    accept
    Wait For Elements State    id=next_page_url    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/div    delay=500ms    force=True
    Sleep    1s
    Fill Text    id=iframe_device >>> input[id=page_txt]    Lestrade
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms
    Wait For Elements State    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='Lestrade']    visible    15s
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/div    delay=500ms    force=True
    Sleep    1s
    Wait For Element And Click It    id=iframe_device >>> id=Del_page_Btn
    # alert 會被自動處理
    Wait For Elements State    id=next_page_url    visible

新增頁面
    [Tags]    page
    Wait For Elements State    css=body    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    id=addmenu
    Wait For Elements State    id=iframe_device >>> css=body    visible    15s
    Click   id=iframe_device >>> id=menu_txt
    Fill Text    id=iframe_device >>> input[id=menu_txt]    robot
    Click With Options   id=iframe_device >>> id=nav_ic_ac_div    force=True
    ${border_color}=    Get Style    id=iframe_device >>> id=nav_ic_ac_div    border-color
    Should Be Equal    ${border_color}    rgb(126, 192, 67)
    Click   id=iframe_device >>> id=go_toSet_page_btn
    Wait For Elements State    id=iframe_device >>> id=page_txt    visible    15s
    Fill Text    id=iframe_device >>> id=page_txt    robot1
    Sleep    1s
    Click   id=iframe_device >>> id=page_edit_submit
    sleep    1s

刪除頁面
    [Tags]    page
    Wait For Elements State    css=body    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    id=Setting_Btn
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Hover    css=body
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[2]/ul/li[2]    delay=100ms
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Wait For Elements State    id=next_page_url >>> .table.table-hover    stable
    Click With Options    id=next_page_url >>> xpath=/html/body/div/div[2]/section[2]/div[2]/div/table/tbody/tr[last()]/td[4]/div/button[2]    delay=500ms
    Wait For Elements State    id=next_page_url >>> .modal.fade.show    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div[4]/div/div/div[2]/div/button[1]
    Wait For Elements State    css=body    visible    15s
    ${page}    Get Text    id=next_page_url >>> /html/body/div/div[2]/section[2]/div[2]/div/table/tbody/tr[last()]/td[1]/div/p
    Should Not Be Equal    ${page}    robot