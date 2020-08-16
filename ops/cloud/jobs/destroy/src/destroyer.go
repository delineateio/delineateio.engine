package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	gcrauthn "github.com/google/go-containerregistry/pkg/authn"
)

const terraform = "terraform"
const lock = "-lock=true"
const refresh = "-refresh=true"
const auto = "-auto-approve"

// Destroyer is a gcr cleaner.
type Destroyer struct {
	auther gcrauthn.Authenticator
}

// NewDestroyer creates a new GCR cleaner with the given token provider
func NewDestroyer(auther gcrauthn.Authenticator) (*Destroyer, error) {
	return &Destroyer{
		auther: auther,
	}, nil
}

func newDestroyContext(payload payload) destroyContext {

	return destroyContext{
		env:        payload.Env,
		project:    os.Getenv("GOOGLE_PROJECT"),
		url:        payload.RepoURL,
		root:       payload.RepoRoot,
		components: payload.Components,
	}
}

// DestroyContext holds the value for the destroy
type destroyContext struct {
	env        string
	project    string
	url        string
	root       string
	components []string
	current    string
}

func newCommandInfo(ctx destroyContext, app string, params []string, output bool) commandInfo {

	return commandInfo{
		ctx:    ctx,
		app:    app,
		params: params,
		output: output,
	}
}

type commandInfo struct {
	ctx    destroyContext
	app    string
	params []string
	output bool
}

// Destroy remove the infrastructure
func (d *Destroyer) Destroy(payload payload) error {

	ctx := newDestroyContext(payload)

	// Clones the existing repo
	err := clone(ctx)
	if err != nil {
		return err
	}

	for i := 0; i < len(ctx.components); i++ {
		ctx.current = ctx.root + ctx.components[i]
		err := destroy(ctx)
		if err != nil {
			return err
		}
	}

	return nil
}

func clone(ctx destroyContext) error {

	err := execute(removeRepo(ctx))
	if err != nil {
		return err
	}

	err = execute(cloneRepo(ctx))
	if err != nil {
		return err
	}

	return nil
}

func destroy(ctx destroyContext) error {

	err := execute(getInit(ctx))
	if err != nil {
		return err
	}

	err = execute(getDestroy(ctx))
	if err != nil {
		return err
	}

	return nil
}

func removeRepo(ctx destroyContext) commandInfo {

	return newCommandInfo(ctx, "rm", []string{"-rf", ctx.root}, false)
}

func cloneRepo(ctx destroyContext) commandInfo {

	return newCommandInfo(ctx, "git", []string{"clone", ctx.url, ctx.root}, false)
}

func print(info commandInfo) error {

	fmt.Println(info.app, strings.Join(info.params, " "))
	return nil
}

func execute(info commandInfo) error {

	print(info)

	cmd := exec.Command(info.app, info.params...)
	cmd.Dir = info.ctx.current

	if info.output {
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}

	err := cmd.Run()

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	return nil
}

func getInit(ctx destroyContext) commandInfo {

	bucket := fmt.Sprintf("-backend-config=bucket=%s-tf", ctx.project)

	return newCommandInfo(ctx, terraform, []string{"init", bucket}, false)
}

func getDestroy(ctx destroyContext) commandInfo {

	file := fmt.Sprintf("%s/.circleci/tf/%s.tfvars", ctx.root, ctx.env)
	vars := "-var-file=" + file

	return newCommandInfo(ctx, terraform, []string{"destroy", vars, lock, refresh, auto}, true)
}
