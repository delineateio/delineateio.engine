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
func (customers *CustomerRepository) Migrate() error {
	err := customers.core.Open()
	if err != nil {
		return err
	}

	err = customers.core.Database.AutoMigrate(&Customer{}).Error
	if err != nil {
		// better to report the earlier error
		l.Error("db.migrate.error", err)
		_ = customers.core.Close()
		return err
	}

	err = customers.core.Close()
	if err != nil {
		return err
	}

	l.Info("db.migrate", "successfully migrate the db")
	return nil
}

// CreateCustomer adds the customer object to the database
func (customers *CustomerRepository) CreateCustomer(customer *Customer) error {
	err := customers.Open()
	if err != nil {
		return err
	}

	err = customers.core.Database.Create(&customer).Error
	if err != nil {
		l.Error("customer.create", err)
	}

	err = customers.Close()
	if err != nil {
		return err
	}

	return nil
}

// Ping wrapper around the core implementation
func (customers *CustomerRepository) Ping() error {
	return customers.core.Ping()
}

// Open wrapper around the core implementation
func (customers *CustomerRepository) Open() error {
	return customers.core.Open()
}

// Close wrapper around the core implementation
func (customers *CustomerRepository) Close() error {
	return customers.core.Close()
}
