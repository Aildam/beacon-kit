// SPDX-License-Identifier: MIT
//
// Copyright (c) 2024 Berachain Foundation
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

package manager

import (
	"context"

	"github.com/berachain/beacon-kit/mod/log"
	"github.com/berachain/beacon-kit/mod/storage/pkg/pruner"
)

// DBManager is a manager for all pruners.
type DBManager struct {
	Pruners map[string]*pruner.Pruner
	// Pruners []*pruner.Pruner
	logger log.Logger[any]
}

func NewDBManager(opts ...DBManagerOption) (*DBManager, error) {
	m := &DBManager{
		Pruners: make(map[string]*pruner.Pruner),
	}
	for _, opt := range opts {
		if err := opt(m); err != nil {
			return nil, err
		}
	}
	return m, nil
}

// Name returns the name of the Basic Service.
func (m *DBManager) Name() string {
	return "DBManager"
}

// TODO: fr implementation
func (m *DBManager) Status() error {
	return nil
}

// TODO: fr implementation
func (m *DBManager) WaitForHealthy(_ context.Context) {
}

// Start starts all pruners.
func (m *DBManager) Start(ctx context.Context) error {
	for _, pruner := range m.Pruners {
		pruner.Start(ctx)
	}
	return nil
}

// notifies all pruners to prune with the given index.
func (m *DBManager) NotifyAll(index uint64) {
	for _, pruner := range m.Pruners {
		pruner.Notify(index)
	}
}

// notifies the pruner with the given name to prune with the given index.
func (m *DBManager) Notify(name string, index uint64) {
	pruner, ok := m.Pruners[name]
	if !ok {
		m.logger.Error("Pruner not found", "name", name)
		return
	}
	pruner.Notify(index)
}
