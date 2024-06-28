// SPDX-License-Identifier: BUSL-1.1
//
// Copyright (C) 2024, Berachain Foundation. All rights reserved.
// Use of this software is governed by the Business Source License included
// in the LICENSE file of this repository and at www.mariadb.com/bsl11.
//
// ANY USE OF THE LICENSED WORK IN VIOLATION OF THIS LICENSE WILL AUTOMATICALLY
// TERMINATE YOUR RIGHTS UNDER THIS LICENSE FOR THE CURRENT AND ALL OTHER
// VERSIONS OF THE LICENSED WORK.
//
// THIS LICENSE DOES NOT GRANT YOU ANY RIGHT IN ANY TRADEMARK OR LOGO OF
// LICENSOR OR ITS AFFILIATES (PROVIDED THAT YOU MAY USE A TRADEMARK OR LOGO OF
// LICENSOR AS EXPRESSLY REQUIRED BY THIS LICENSE).
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE LICENSED WORK IS PROVIDED ON
// AN “AS IS” BASIS. LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS,
// EXPRESS OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND
// TITLE.

package cometbft

import (
	"log"

	"cosmossdk.io/core/transaction"
	serverv2 "cosmossdk.io/server/v2"
	sdkcomet "cosmossdk.io/server/v2/cometbft"
	"cosmossdk.io/store/v2/snapshots"
	"github.com/berachain/beacon-kit/mod/consensus/pkg/cometbft"
	"github.com/berachain/beacon-kit/mod/node-core/pkg/types"
	"github.com/spf13/viper"
)

// assert that CometBFTServer implements the ServerComponent interface
var _ serverv2.ServerComponent[
	types.Node[transaction.Tx], transaction.Tx,
] = (*Server[
	types.Node[transaction.Tx], transaction.Tx, any,
])(nil)

// Server is a wrapper around the Server from the Cosmos SDK.
type Server[
	NodeT types.Node[T], T transaction.Tx, ValidatorUpdateT any,
] struct {
	*sdkcomet.CometBFTServer[NodeT, T]
	// TxCodec transaction.Codec[T]
}

func NewServer[
	NodeT types.Node[T], T transaction.Tx, ValidatorUpdateT any,
](
	txCodec transaction.Codec[T],
	consensus *cometbft.ConsensusEngine[T, ValidatorUpdateT],
) *Server[NodeT, T, ValidatorUpdateT] {
	options := sdkcomet.DefaultServerOptions[T]()
	options.PrepareProposalHandler = consensus.PrepareProposal
	options.ProcessProposalHandler = consensus.ProcessProposal
	return &Server[NodeT, T, ValidatorUpdateT]{
		sdkcomet.New[NodeT, T](txCodec, options),
	}
}

// Init wraps the default Init method and sets the PrepareProposal and
// ProcessProposal handlers.
func (s *Server[NodeT, T, ValidatorUpdateT]) Init(
	node NodeT, v *viper.Viper, logger log.Logger,
) error {
	s.Config = sdkcomet.Config{CmtConfig: sdkcomet.GetConfigFromViper(v), ConsensusAuthority: node.GetConsensusAuthority()}
	// TODO: set these; what is the appropriate presence of the Store interface here?
	var ss snapshots.StorageSnapshotter
	var sc snapshots.CommitSnapshotter

	snapshotStore, err := sdkcomet.GetSnapshotStore(s.Config.CmtConfig.RootDir)
	if err != nil {
		return err
	}

	sm := snapshots.NewManager(snapshotStore, s.Options.SnapshotOptions, sc, ss, nil, s.logger)
	s.Consensus.SetSnapshotManager(sm)
	return nil
}
