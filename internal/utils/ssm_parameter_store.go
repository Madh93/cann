package utils

import (
	"bytes"
	"context"
	"fmt"
	"html/template"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

type SSMParameter struct {
	Name  string
	Value string
}

// Get the value of a single SSM parameter by specifying the parameter name.
func GetSSMParameterValue(client *ssm.Client, ctx context.Context, name string) (value string, err error) {
	response, err := client.GetParameter(ctx, &ssm.GetParameterInput{
		Name:           aws.String(name),
		WithDecryption: true,
	})
	if err != nil {
		err = fmt.Errorf("unable to get '%s' parameter from SSM, %w", name, err)
		return
	}

	value = *response.Parameter.Value
	return
}

// Get the value of a single SSM parameter by specifying the parameter name of a
// list of parameters.
func GetSSMParameterValueFrom(parameters []SSMParameter, name string) (value string, err error) {
	for _, parameter := range parameters {
		if parameter.Name == name {
			value = parameter.Value
			return
		}
	}

	err = fmt.Errorf("unable to get '%s' from list of parameters", name)

	return
}

// Retrieve information about one or more parameters in a specific hierarchy by
// specifying a path.
func GetSSMParameters(client *ssm.Client, ctx context.Context, path string) (parameters []SSMParameter, err error) {
	response, err := client.GetParametersByPath(ctx, &ssm.GetParametersByPathInput{
		Path:      aws.String(path),
		Recursive: true,
	})
	if err != nil {
		err = fmt.Errorf("unable to get parameters under '%s' path from SSM, %w", path, err)
		return
	}

	parameters = []SSMParameter{}
	for _, p := range response.Parameters {
		parameters = append(parameters, SSMParameter{
			Name:  *p.Name,
			Value: *p.Value,
		})
	}

	return
}

// Parse a SSM Parameter Template with the Announcement ID.
func ParseSSMParemeterTemplate(parameter string, announcementID string) (value string, err error) {
	t, err := template.New("parameterTemplate").Parse(parameter)
	if err != nil {
		return
	}

	vars := map[string]string{
		"AnnouncementID": announcementID,
	}

	var b bytes.Buffer
	err = t.Execute(&b, vars)
	if err != nil {
		return
	}

	value = b.String()

	return
}
