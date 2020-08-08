package main

import (
	"fmt"
	"os"
	"os/exec"

	gcrauthn "github.com/google/go-containerregistry/pkg/authn"
)

const terraform = "terraform"
const lock = "-lock=true"
const refresh = "-lock=true"
const auto = "-auto-approve"
const plan = "/tmp/plan.out"

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

func newDestroyContext() destroyContext {

	return destroyContext{
		project: os.Getenv("GOOGLE_PROJECT"),
		env:     os.Getenv("DIO_ENV"),
		url:     os.Getenv("DIO_REPO_URL"),
		root:    os.Getenv("DIO_REPO_ROOT"),
		dir:     ".",
	}
}

// DestroyContext holds the value for the destroy
type destroyContext struct {
	project string
	env     string
	root    string
	url     string
	dir     string
}

func newCommandInfo(ctx destroyContext, app string, params []string) commandInfo {

	return commandInfo{
		ctx:    ctx,
		app:    app,
		params: params,
	}
}

type commandInfo struct {
	ctx    destroyContext
	app    string
	params []string
}

func (c *commandInfo) print() {

	fmt.Println(c.app)
	fmt.Println(c.params)
}

// Destroy remove the infrastructure
func (d *Destroyer) Destroy(components []string) error {

	ctx := newDestroyContext()

	// Clones the existing repo
	err := clone(ctx)
	if err != nil {
		return err
	}

	for i := 0; i < len(components); i++ {
		ctx.dir = getDir(ctx, components[i])
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

func removeRepo(ctx destroyContext) commandInfo {

	return newCommandInfo(ctx, "rm", []string{"-rf", ctx.root})
}

func cloneRepo(ctx destroyContext) commandInfo {

	return newCommandInfo(ctx, "git", []string{"clone", ctx.url, ctx.root})
}

func destroy(ctx destroyContext) error {

	err := execute(getInit(ctx))
	if err != nil {
		return err
	}

	err = execute(getPlan(ctx))
	if err != nil {
		return err
	}

	err = execute(getApply(ctx))
	if err != nil {
		return err
	}

	return nil
}

// func print(info commandInfo) error {

//	info.print()
//	return nil
// }

func execute(info commandInfo) error {

	info.print()

	cmd := exec.Command(info.app, info.params...)
	cmd.Dir = info.ctx.dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	return nil
}

func getInit(ctx destroyContext) commandInfo {

	bucket := fmt.Sprintf("-backend-config=bucket=%s-tf", ctx.project)

	return newCommandInfo(ctx, terraform, []string{"init", bucket})
}

func getDir(ctx destroyContext, component string) string {

	return ctx.root + "/ops/cloud/" + component
}

func getPlan(ctx destroyContext) commandInfo {

	file := fmt.Sprintf("%s/.circleci/tf/%s.tfvars", ctx.root, ctx.env)
	vars := "-var-file=" + file
	out := fmt.Sprintf("-out=%s", plan)

	return newCommandInfo(ctx, terraform, []string{"plan", vars, lock, refresh, out})
}

func getApply(ctx destroyContext) commandInfo {

	return newCommandInfo(ctx, terraform, []string{"apply", lock, refresh, auto, plan})
}
