*** Settings ***
Resource    ./task.robot
Suite Setup    Initialize Browser

*** Test Cases ***
登入
    New Page    ${url}    load
    Fill Text    id=account    ${acc}
    Fill Text    id=password    ${pw}
    Click    id=loginBtn
    Wait For Load State    load    30
    Wait For Elements State    css=body    visible    15s
    Wait For Elements State    .wrapper    visible    30s
    ${current_url}=    Get Url
    Set Global Variable    ${main_url}    ${current_url}