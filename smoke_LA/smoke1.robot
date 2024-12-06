*** Settings ***
Resource    ./task.robot
Suite Setup    Refresh Url

*** Keywords ***
Refresh url
    New Browser    chromium    headless=False    slowMo=1
    New Page    ${main_url}&uid=${uid}&title=robot_page&em=Add

*** Test Cases ***
新增標籤
    [Tags]    label
    Go To    ${main_url}&uid=${uid}&title=robot_page&em=Add
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Wait For Element And Click It    id=next_page_url >>> //span[@data-i18n='index.button.add_page_tag' and text()='Add Tab']
    Wait For Elements State    id=iframe_device >>> css=body    visible
    Fill Text    id=iframe_device >>> input[id=page_txt]    robot2
    Sleep    1s
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms
    Get Text    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/p    ==    robot2
    Wait For Element And Click It    id=next_page_url >>> //span[@data-i18n='index.button.add_page_tag' and text()='Add Tab']
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
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    -60
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    0    5
    Mouse Move Relative To    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    0    -10
    Mouse Button    up
    Get Text    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/p    ==    robot1

編輯,刪除標籤
    [Documentation]    label
    Handle Future Dialogs    accept
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/div    delay=500ms    force=True
    Sleep    1s
    Fill Text    id=iframe_device >>> input[id=page_txt]    Lestrade
    Click With Options    id=iframe_device >>> id=page_edit_submit    delay=100ms
    Wait For Elements State    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='Lestrade']    visible    15s
    Click With Options    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[1]/div[2]/div[1]/div    delay=500ms    force=True
    Sleep    1s
    Wait For Element And Click It    id=iframe_device >>> id=Del_page_Btn
    # alert 會被自動處理
    Wait For Elements State    id=next_page_url >>> css=body    visible