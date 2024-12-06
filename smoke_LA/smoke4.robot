*** Settings ***
Resource    ./task.robot
Suite Setup    Refresh Url

*** Keywords ***
Refresh url
    New Browser    chromium    headless=False    slowMo=1
    New Page    ${url}/event/eventList.html?token=${token}&language=en

*** Test Cases ***
