package main

import (
	l "github.com/delineateio/core/logging"
	r "github.com/delineateio/core/repository"
)

// CustomerRepository that reprents the access to the underlying database
type CustomerRepository struct {
	core *r.Repository
}

// NewCustomerRepository returns production database access
func NewCustomerRepository() *CustomerRepository {

	return &CustomerRepository{
		core: r.NewRepository("customers"),
	}
}

// Migrate the DB to the latest schema
func (r *CustomerRepository) Migrate() error {

	err := r.core.Open()
	if err != nil {
		return err
	}

	err = r.core.Database.AutoMigrate(&Customer{}).Error
	if err != nil {
		// better to report the earlier error
		l.Error("db.migrate.error", err)
		_ = r.core.Close()
		return err
	}

	err = r.core.Close()
	if err != nil {
		return err
	}

	l.Info("db.migrate", "successfully migrate the db")
	return nil
}

// CreateCustomer adds the customer object to the database
func (r *CustomerRepository) CreateCustomer(customer Customer) error {

	err := r.Open()
	if err != nil {
		return err
	}

	err = r.core.Database.Create(&customer).Error
	if err != nil {
		l.Error("customer.create", err)
	}

	err = r.Close()
	if err != nil {
		return err
	}

	return nil
}

// Ping wrapper around the core implementation
func (r *CustomerRepository) Ping() error {
	return r.core.Ping()
}

// Open wrapper around the core implementation
func (r *CustomerRepository) Open() error {
	return r.core.Open()
}

// Close wrapper around the core implementation
func (r *CustomerRepository) Close() error {
	return r.core.Close()
}
