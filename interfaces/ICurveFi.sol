// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;
interface ICurveFi {
  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;
  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);
  function get_dx_underlying(
    int128 i,
    int128 j,
    uint256 dy
  ) external view returns (uint256);
  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);
  function get_dx(
    int128 i,
    int128 j,
    uint256 dy
  ) external view returns (uint256);
  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);
  function get_virtual_price() external view returns (uint256);
}