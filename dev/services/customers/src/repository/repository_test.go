package data

//TODO: Need to write unit tests for callbacks

import (
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	c "github.com/delineateio/core/config"
	"github.com/jinzhu/gorm"
	"github.com/stretchr/testify/assert"
)

func loadUnitTestConfig() {

	var configurator = c.Configurator{
		Env:      "repository",
		Location: "../../tests",
	}
	configurator.Load()
}

func TestUTDefaultDatabaseType(t *testing.T) {

	r := NewRepository("missing")

	dbType, err := r.getDatabaseType()

	assert.Equal(t, dbType, DefaultDBType)
	assert.NoError(t, err)
}

func TestUTGetConfigDatabaseType(t *testing.T) {

	loadUnitTestConfig()

	r := NewRepository("mysql")
	r.AllowedDBTypes = []string{DefaultDBType, "mysql"}

	dbType, err := r.getDatabaseType()
	assert.NoError(t, err)
	assert.Equal(t, dbType, "mysql")
}

func TestUTDBTypeNotAllowed(t *testing.T) {

	loadUnitTestConfig()

	r := NewRepository("sqllite")
	r.AllowedDBTypes = []string{DefaultDBType, "mysql"}

	dbType, err := r.getDatabaseType()
	assert.Error(t, err)
	assert.Equal(t, dbType, DefaultDBType)
}

func TestUTConnectionStringNotSet(t *testing.T) {

	r := NewRepository("postgres")
	r.DBConnectionStringKey = ""

	connection, err := r.getConnectionString()
	assert.Error(t, err)
	assert.Equal(t, connection, "")
}

func TestUTGetConfigConnectionString(t *testing.T) {

	loadUnitTestConfig()

	r := NewRepository("postgres")
	connection, err := r.getConnectionString()
	assert.NoError(t, err)
	assert.Equal(t, connection, "postgres://postgres:postgres@postgres/postgres")
}

func TestUTOpenFailsNoDBType(t *testing.T) {

	loadUnitTestConfig()

	r := NewRepository("postgres")
	r.DBTypeKey = ""

	err := r.Open()
	assert.Error(t, err)
}

func TestUTOpenFailsNoDBConnectionString(t *testing.T) {

	loadUnitTestConfig()

	r := NewRepository("postgres")
	r.DBConnectionStringKey = ""

	err := r.Open()
	assert.Error(t, err)
}

func TestUTOpenTryAttempts(t *testing.T) {

	loadUnitTestConfig()

	r := NewRepository("postgres")
	assert.Equal(t, r.Attempts, uint(3))

	// Changes from the default
	attempts := 2
	r.Attempts = uint(attempts)

	assert.Error(t, r.Open())
	assert.Equal(t, r.Info.Tries, attempts)
}

func TestUTMainDBFuncs(t *testing.T) {

	loadUnitTestConfig()

	// Sets up the base repository and overrides
	r := NewRepository("postgres")

	// Creates the mock for testing purposes
	db, mock, err := sqlmock.New()

	assert.NoError(t, err) // Asserts there is no error

	// Sets up assert tests
	// mock.ExpectPing()
	mock.ExpectClose()

	// Replaces the default handler for setting the database
	r.SetDBFunc = func() (*gorm.DB, error) {
		return gorm.Open("postgres", db) // open gorm db
	}

	// Checks that no issues are encountered and
	// expectations met
	assert.NoError(t, r.Open())
	assert.Error(t, r.Migrate()) // Expected to fail
	assert.NoError(t, r.Close())
	assert.NoError(t, mock.ExpectationsWereMet())
}
