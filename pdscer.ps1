<# 
.DESCRIPTION
PagerDuty Onboarding and Service Event Creation
Owner: Rory Parker
#> 

# Team Creation
$headers=@{}
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/vnd.pagerduty+json;version=2")
$headers.Add("Authorization", "Token token=yyyyyyyyyyyyy") # need to use runbook to secure it with automation variabal 
$Summary = "Your Summary"
$con1 = "PD - Your Summary"
$Con2 = "PROD - Response Time"
$Con3= "PD - Critical"
#$Scom_con1 = "ODS BESL 11110"
$Summary_2 = "Your Summary 2"
$con1_2 = "PD - Your Summary"
$Con2_2 = "PD - Your Summary"
#------------------Service Creation Json------------------------------------------
$SC = '{
"service": {
"type": "service",
"name": "Dhaval-API1",
"auto_resolve_timeout": null,
"acknowledgement_timeout": null,
"status": "active",
"escalation_policy": {
"id": "YYYYYY", 
"type": "escalation_policy_reference"
},
"incident_urgency_rule": {
"type": "constant",
"urgency": "severity_based"
},
"support_hours": null,
"scheduled_actions": [

],
"alert_creation": "create_alerts_and_incidents",
"alert_grouping": "intelligent",
"alert_grouping_timeout": null,
"alert_grouping_parameters": {
"type": "intelligent",
"config": null
}
}
}'
$SC1 = $SC | ConvertFrom-Json
#---------------------------------------------------------------
# Creating Event Rules-----------
$Rule1 = '{
  "rule": {
    "id": "1eb2ced1-xxx-xxx-xxxx-xxxxxxxxx2621",
    "actions": {
       "annotate": null,
        "automation_actions": [],
        "event_action": null,
        "extractions": [
          {
            "target": "summary",
            "template": "ChangeMe"
          }
        ],
        "priority": {
          "value": "YYYYYYY"
        },
        "route": {
          "value": "YYYYYY"
        },
        "severity": {
          "value": "critical"
        },
        "suppress": null,
        "suspend": {
          "value": 300
        }
      },
      "catch_all": false,
      "conditions": {
        "operator": "and",
        "subconditions": [
          {
            "operator": "contains",
            "parameters": {
              "path": "data.essentials.alertRule",
              "value": "Your Summary"
            }
          },
          {
            "operator": "contains",
            "parameters": {
              "path": "data.essentials.alertRule",
              "value": "Your Summary"
            }
          }
        ]
      },
      "disabled": false 
}
}'
#-----------------------------------------------------------------------------
#---------------------------------------------------------------
$Rule2 = '{
  "rule": {
    "id": "1eb2ced1-xxx-xxx-xxxx-xxxxxxxxx2621",
    "actions": {
        "annotate": null,
        "automation_actions": [],
        "event_action": null,
        "extractions": [
          {
            "target": "summary",
            "template": "ChangeMe"
          }
        ],
        "priority": {
          "value": "YYYYYYY"
        },
        "route": {
          "value": "YYYYYY"
        },
        "severity": {
          "value": "critical"
        },
        "suppress": null,
        "suspend": {
          "value": 300
        }
      },
      "catch_all": false,
      "conditions": {
        "operator": "and",
        "subconditions": [
          {
            "operator": "contains",
            "parameters": {
              "path": "data.essentials.alertRule",
              "value": "Your Summary"
            }
          },
          {
            "operator": "contains",
            "parameters": {
              "path": "data.essentials.alertRule",
              "value": "Your Summary"
            }
          }
        ]
      },
      "disabled": false 
}
}'
#-----------------------------------------------------------------------------
#----------------Event Rule 3-----------------
$Rule3 = '{
  "rule": {
    "id": "1eb2ced1-xxx-xxx-xxxx-xxxxxxxxx2621",
"actions": {
        "annotate": {
          "value": "Please Look into This Alerts And Open an Incident If its Require"
        },
        "automation_actions": [],
        "event_action": null,
        "extractions": [],
        "priority": {
          "value": "YYYYYYY"
        },
        "route": {
          "value": "YYYYYY"
        },
        "severity": {
          "value": "warning"
        },
        "suppress": null,
        "suspend": {
          "value": 300
        }
      },
      "catch_all": false,
      "conditions": {
        "operator": "and",
        "subconditions": [
          {
            "operator": "contains",
            "parameters": {
              "path": "data.essentials.alertRule",
              "value": "Your Summary"
            }
          }
        ]
      },
      "disabled": false 
}
}'
#-------------------------

$temp = Import-Csv "C:\pd\listofyourteam.csv"
$array=@()
foreach($value in $temp)
{
$jsonBase = @{}
$array = @{}
$data = @{"name"=$value.name;"type"="team";}
$array.Add("name",$value)
#$array.Add("type"="team")
$jsonBase.Add("team",$data)
#$jsonBase | ConvertTo-Json -Depth 10
$team= $jsonBase | ConvertTo-Json
$response = Invoke-RestMethod -Uri 'https://api.pagerduty.com/teams' -Method POST -Headers $headers -ContentType 'application/json' -Body $team 
# Get the Name of Team to use it for Service Creation
$SC1.service.name = $response.team.name 
$Servicebody = $SC1 | ConvertTo-Json]
$response_sc1 = Invoke-RestMethod -Uri 'https://api.pagerduty.com/services' -Method POST -Headers $headers -ContentType 'application/json' -Body $Servicebody
# Event Rule 1 Creation
$b = $Rule1 | ConvertFrom-Json
$b.rule.actions.route.value = $response_sc1.service.id
$foundItem = $b.rule.actions.extractions  | Where-Object { $_.template -eq "ChangeMe" }
$foundItem.template =$response_sc1.service.name+" "+$Summary
$par= $b.rule.conditions.subconditions | Where-Object { $_.parameters.value -eq  "Your Summary" }
$par.parameters.value = $response_sc1.service.name+" - "+$Con1
$par1= $b.rule.conditions.subconditions | Where-Object { $_.parameters.value -eq  "Your Summary" }
$par1.parameters.value = $response_sc1.service.name+" - "+$Con2
$rule1body= $b | ConvertTo-Json -Depth 10
$response_rule1 = Invoke-RestMethod -Uri 'https://api.pagerduty.com/rulesets/1eb2ced1-xxx-xxx-xxxx-xxxxxxxxx2621/rules' -Method POST -Headers $headers -ContentType 'application/json' -Body $rule1body
# Event Rule 2 Creation
$c = $Rule2 | ConvertFrom-Json
$c.rule.actions.route.value = $response_sc1.service.id
$foundItem = $c.rule.actions.extractions  | Where-Object { $_.template -eq "ChangeMe" }
$foundItem.template =$response_sc1.service.name+" "+$Summary_2
$par= $c.rule.conditions.subconditions | Where-Object { $_.parameters.value -eq  "Your Summary" }
$par.parameters.value = $response_sc1.service.name+" - "+$Con1_2
$par1= $c.rule.conditions.subconditions | Where-Object { $_.parameters.value -eq  "Your Summary" }
$par1.parameters.value = $response_sc1.service.name+" - "+$Con2_2
$rule2body= $c | ConvertTo-Json -Depth 10
$response_rule2 = Invoke-RestMethod -Uri 'https://api.pagerduty.com/rulesets/1eb2ced1-xxx-xxx-xxxx-xxxxxxxxx2621/rules' -Method POST -Headers $headers -ContentType 'application/json' -Body $rule2body
# Event Rule 3 Creation
$d = $Rule3 | ConvertFrom-Json
$d.rule.actions.route.value = $response_sc1.service.id
$par= $d.rule.conditions.subconditions | Where-Object { $_.parameters.value -eq  "Your Summary" }
$par.parameters.value = $response_sc1.service.name+" - "+$Con3
$rule3body= $d | ConvertTo-Json -Depth 10
$response_rule3 = Invoke-RestMethod -Uri 'https://api.pagerduty.com/rulesets/1eb2ced1-xxx-xxx-xxxx-xxxxxxxxx2621/rules' -Method POST -Headers $headers -ContentType 'application/json' -Body $rule3body
# Scom Event Rule for ODS BESL Event Rule ODS BESL 11110 Creation
#--$d = $Rule3 | ConvertFrom-Json
#$d.rule.actions.route.value = $response_sc1.service.id
#$par= $d.rule.conditions.subconditions | Where-Object { $_.parameters.value -eq  "Your Summary" }
#$par.parameters.value = $Scom_con1
#$rule3body= $d | ConvertTo-Json -Depth 10
#$response_rule3 = Invoke-RestMethod -Uri 'https://api.pagerduty.com/rulesets/1eb2ced1-xxx-xxx-xxxx-xxxxxxxxx2621/rules' -Method POST -Headers $headers -ContentType 'application/json' -Body $rule3body
}

