# Macnman Production Firmware Hex Files

Central repository for **production-release firmware hex files** of Macnman MacSync devices, together with the hardware test result for each build.

Only signed-off, production-ready builds are published here. Development and test builds live in their respective firmware source repositories.

## Model number format

### New nomenclature (since 2026-10-28)

New and renamed models use the Macnman model number nomenclature: `Family - Communication + Power + Storage - Function - Hardware revision`.

```
MY - L 1 D - TH - X1
 |   | | |    |    |
 |   | | |    |    +-- hardware revision (X1, X2, ...)
 |   | | |    +------- function: TS, TH, PS, WS, US, GS, NS (sensors); CV converter, CT controller, BN beacon
 |   | | +------------ D = datalogger (flash storage); no letter = no flash
 |   | +-------------- power: 1 battery, 2 solar + battery, 3 DC 24 V, 4 PoE, 5 mains (AC)
 |   +---------------- communication: L LoRaWAN, M MacTalk, C cellular, W Wi-Fi, B BLE
 +-------------------- family: MS MacSet, MY MacSync, ML MacLink
```

- Power class folder: power `1` or `2` → `MacSync_LBO`; power `3`, `4` or `5` → `MacSync_LPO`.
- Model folder: the model number with `_` separators (`MY_L1_TH_X1`). Hex files: `MY-L1-TH-X1.hex` and `BLE-MY-L1-TH-X1.hex`.
- The BLE images of renamed models still advertise their old names, as the Maya app expects.

| Model | Was | Folder |
| --- | --- | --- |
| `MY-L1-TH-X1` | `MacSync-LBS-TH-X1` | `MacSync_LBO/MY_L1_TH_X1` |
| `MY-L3-CV-X1` | `MacSync-LPS-STD-X1` | `MacSync_LPO/MY_L3_CV_X1` |
| `MS-L5-CT-X1` | `MS-LPC-ST-X1` (new here) | `MacSync_LPO/MS_L5_CT_X1` |

### Older format

The other models keep the older format below until they are renamed. Every older model number encodes its own metadata:

```
MacSync - L B S - TH - X1
   |      | | |    |    |
   |      | | |    |    +-- hardware revision (X1, X2, ...)
   |      | | |    +------- measurement / payload (TH, NS, ToF, DRS, STD, PO)
   |      | | +------------ S = Sensor, D = Datalogger
   |      | +-------------- B = Battery powered, P = externally Powered
   |      +---------------- L = LoRaWAN, M = raw LoRa (point-to-point)
   +----------------------- product family
```

| Position | Code | Meaning |
| --- | --- | --- |
| 1 | `L` | LoRaWAN |
| 1 | `M` | Raw LoRa (point-to-point) |
| 2 | `B` | Battery powered (folder `MacSync_LBO`) |
| 2 | `P` | Externally powered (folder `MacSync_LPO`) |
| 3 | `S` | Sensor |
| 3 | `D` | Datalogger |

Payload codes: `TH` (temperature + humidity), `NS`, `ToF`, `DRS` (door reed switch), `STD`, `PO`.

Worked example — `MacSync-LBD-STD-X1`: LoRaWAN, Battery powered, Datalogger, STD payload, hardware revision X1.

## Repository structure

```
Macnman_Production_Firmware_Hex_Files/
├── MacSync_LBO/                              # LoRa, Battery Operated
│   ├── MY_L1_TH_X1/                          # LoRaWAN build (was MacSync_LBS_TH_X1)
│   │   ├── hw_result.json
│   │   ├── Application/
│   │   │   ├── NrF52810/
│   │   │   │   └── BLE-MY-L1-TH-X1.hex
│   │   │   └── STM32WLE5CBU6/
│   │   │       └── MY-L1-TH-X1.hex
│   │   └── Testing/
│   │       ├── NrF52810/
│   │       │   └── nRF52810_JIG_Testing.hex
│   │       └── STM32WLE5CBU6/
│   │           └── LoRa_Jig_Testing_SHT40_Sensor.hex
│   ├── MacSync_MBS_TH_X1/
│   │   ├── hw_result.json                    # one per model
│   │   ├── Application/                      # shipping firmware
│   │   │   ├── NrF52/
│   │   │   │   └── BLE-MS-MBS-TH-X1.hex
│   │   │   └── STM32WLE5CBU6/
│   │   │       └── MS-MBS-TH-X1.hex
│   │   └── Testing/                          # JIG test firmware
│   │       ├── NrF52810/
│   │       │   └── nRF52810_JIG_Testing.hex
│   │       └── STM32WLE5CBU6/
│   │           └── LoRa_Jig_Testing_SHT40_Sensor.hex
│   └── MacSync_MBS_DRS_X1/
│       ├── hw_result.json
│       ├── Application/
│       │   ├── NrF52810/
│       │   │   └── BLE-MS-MBS-DRS-X1.hex
│       │   └── STM32WLE5CBU6/
│       │       └── MS-MBS-DRS-X1.hex
│       └── Testing/
│           ├── NrF52810/
│           │   └── nRF52810_JIG_Testing.hex
│           └── STM32WLE5CBU6/
│               └── LoRa_Jig_Testing_SHT40_Sensor.hex
└── MacSync_LPO/                              # LoRa, Power Operated
    ├── MS_L5_CT_X1/                          # LoRaWAN relay controller (was MS-LPC-ST-X1)
    │   ├── hw_result.json
    │   └── Application/                      # no JIG firmware yet
    │       ├── NrF52810/
    │       │   └── BLE-MS-L5-CT-X1.hex
    │       └── STM32WLE5CCU6/
    │           └── MS-L5-CT-X1.hex
    ├── MY_L3_CV_X1/                          # LoRaWAN build, RS485 + analog (was MacSync_LPS_STD_X1)
    │   ├── hw_result.json
    │   ├── Application/
    │   │   ├── NrF52810/
    │   │   │   └── BLE-MY-L3-CV-X1.hex
    │   │   └── STM32WLE5CBU6/
    │   │       └── MY-L3-CV-X1.hex
    │   └── Testing/
    │       ├── NrF52810/
    │       │   └── nRF52810_JIG_LPO_Testing.hex
    │       └── STM32WLE5CBU6/
    │           └── LoRa_LPO_Jig_Testing_RS485_Analog_Sensor.hex
    └── MS-MPV-X1/
        ├── hw_result.json
        ├── Application/
        │   ├── NrF52810/
        │   │   └── BLE-MS-MPV-X1.hex
        │   └── STM32WLE5CBU6/
        │       └── MS-MPV-X1.hex
        └── Testing/                          # same LPO JIG images as LPS
            ├── NrF52810/
            │   └── nRF52810_JIG_LPO_Testing.hex
            └── STM32WLE5CBU6/
                └── LoRa_LPO_Jig_Testing_RS485_Analog_Sensor.hex
```

`MY_L3_CV_X1/Testing/` holds the firmware flashed onto the board for the LPO JIG test:

| File | Flashed onto | What it is |
| --- | --- | --- |
| `STM32WLE5CBU6/LoRa_LPO_Jig_Testing_RS485_Analog_Sensor.hex` | the board's STM32 | test image, reports `DEVINFO=LORA,NODE,LPO_TEST_JIG,…`; also stores the board's own analog calibration for the shipping firmware |
| `NrF52810/nRF52810_JIG_LPO_Testing.hex` | the board's nRF52810 | SoftDevice + test app, advertises `BLE_LPO_Testing_jig_V1` |

The LBO models' `nRF52810_JIG_Testing.hex` advertises `BLE_Testing_jig_V1`, the name the LBO fixture looks for, so the two nRF test images are not interchangeable. Flash the shipping `Application/` firmware afterwards **without a full-chip erase**, or the board's analog calibration is lost.

Within each stage folder, firmware is separated by target MCU:

| MCU folder | Silicon | Radio | Hex file prefix |
| --- | --- | --- | --- |
| `NrF52` | Nordic nRF52 | BLE | `BLE-MS-…` |
| `NrF52810` | Nordic nRF52810 | BLE | `BLE-MS-…` |
| `STM32WLE5CBU6` | ST STM32WLE5CBU6 | LoRa / LoRaWAN | `MS-…` |
| `STM32WLE5CCU6` | ST STM32WLE5CCU6 | LoRa / LoRaWAN | `MS-…` |

### Folder structure convention

Firmware sits at a four-level path:

```
<power-class>/<model>/<stage>/<mcu>/
        |         |       |      |
        |         |       |      +-- MCU the build targets, e.g. NrF52810, STM32WLE5CBU6
        |         |       +--------- Application or Testing
        |         +----------------- device model folder, e.g. MacSync_MBS_TH_X1
        +--------------------------- MacSync_LBO (battery) or MacSync_LPO (externally powered)
```

| Level | Rule |
| --- | --- |
| `<power-class>` | New format: the power digit, `1` or `2` → `MacSync_LBO`, `3`, `4` or `5` → `MacSync_LPO`. Older format: **position 2** of the model code, `B` → `MacSync_LBO`, `P` → `MacSync_LPO`. Never create a third top-level folder. |
| `<model>` | One folder per device model, named as the model number with `_` separators (e.g. `MacSync_MBS_TH_X1`). One model per folder — do not place another model's firmware here. |
| `<stage>` | `Application` for the production firmware the device ships with; `Testing` for the JIG firmware used to bring the board up on the test fixture. |
| `<mcu>` | One folder per target MCU. A device with two MCUs (radio + application) gets one folder each. |

Each `<mcu>` folder contains only `.hex` firmware images, named per the [file naming convention](#file-naming-convention).

**Exactly one `hw_result.json` per model**, at the model folder root — the level that holds `Application/` and `Testing/`. There is no `hw_result.json` inside the stage or MCU folders.

#### Adding a new device

1. Decode the model number to pick the power class — `B` → `MacSync_LBO`, `P` → `MacSync_LPO`.
2. Create `<power-class>/<model>/` using the model number with `_` separators.
3. Create `Application/` and `Testing/` beneath it, and one `<mcu>/` folder inside each per target MCU.
4. Put the shipping `.hex` in `Application/<mcu>/` and the JIG test `.hex` in `Testing/<mcu>/`.
5. **Add one `hw_result.json` at the model folder root.** List every `.hex` under `firmware`, and include exactly the tests this model requires — see [Rule: list only the tests that model requires](#rule-list-only-the-tests-that-model-requires). Never copy another model's file across unchanged.

Folders are only visible on GitHub once they contain a committed file — an empty folder will not appear.

#### Current deviations

Each model has its own folder, and `MS-MPV-X1` sits under `MacSync_LPO` as its `P` code requires. Two points remain open — see [Naming exceptions to resolve](#naming-exceptions-to-resolve) for detail:

- **`MS-MPV-X1/` is named inconsistently with its siblings.** The other model folders use the full family name with underscores (`MacSync_MBS_TH_X1`); this one uses the abbreviated, hyphenated file-name form. It should be `MacSync_MPV_X1/`.
- **MCU folder names are inconsistent.** `MacSync_MBS_TH_X1/Application/` uses `NrF52`, while everywhere else uses `NrF52810`. Pick either the exact part number or the family and apply it everywhere.
- Resolved 2026-10-28: the `MacSync_LBS_TH_X1` files (`BLE_MS-LBS-TH-X1.hex`, `MacSync_LBS_TH_X1.hex`) now follow the convention as `MY_L1_TH_X1/…/BLE-MY-L1-TH-X1.hex` and `MY-L1-TH-X1.hex`.

## Hardware test results

Each model folder carries exactly one `hw_result.json`, recording the firmware it holds and the outcome of the JIG hardware tests. Every test field is a boolean: `true` = pass, `false` = fail.

```json
{
  "firmware": {
    "application": [
      "Application/NrF52/BLE-MS-MBS-TH-X1.hex",
      "Application/STM32WLE5CBU6/MS-MBS-TH-X1.hex"
    ],
    "testing": [
      "Testing/NrF52810/nRF52810_JIG_Testing.hex",
      "Testing/STM32WLE5CBU6/LoRa_Jig_Testing_SHT40_Sensor.hex"
    ]
  },
  "hw_result": {
    "ble": true,
    "i2c": true,
    "3volt_out": true,
    "capacitor_charge": true,
    "lora_rf": true
  }
}
```

### The firmware field

`firmware` lists every `.hex` present under the model folder, split by stage, as paths relative to the model folder itself.

| Key | Contents |
| --- | --- |
| `application` | Every `.hex` under `Application/`, across all MCU folders. |
| `testing` | Every `.hex` under `Testing/`. Empty array when no JIG firmware exists yet. |

The model number is deliberately **not** stored in the file — it is already the name of the folder the file sits in, and duplicating it only creates a second place to get it wrong.

#### Keeping the lists in sync

**Nothing updates these lists automatically.** Git tracks the `.hex` files and the JSON as unrelated blobs; it has no idea the JSON quotes those paths. Rename an MCU folder or swap in a differently-named build, and the commit succeeds while the JSON silently keeps pointing at a file that no longer exists.

Run the helper after any firmware change, before committing:

```bash
./tools/update_firmware_lists.sh            # rewrite the lists from disk
./tools/update_firmware_lists.sh --check    # report only; exit 1 if stale
```

It rebuilds only the `firmware` block and leaves `hw_result` untouched. The `--check` form is safe to wire into a pre-commit hook or CI job so a stale list fails loudly instead of shipping.

### Rule: list only the tests that model requires

**`hw_result.json` contains one entry per test the board actually has — and nothing else.**

Do not pad the file with tests the hardware does not implement. A `false` must always mean *this test ran and failed*. If absent keys were written as `false`, a genuine failure would be indistinguishable from a test that was never applicable, and the file stops being a usable QA record.

The key set therefore **varies by model**. Consumers must not assume a fixed set of keys — read whichever keys are present, and treat a missing key as "not applicable to this board".

### Test catalogue

| Field | Test | Required when |
| --- | --- | --- |
| `ble` | BLE link to the board's nRF52 - the JIG connects over BLE before every other test | Always — every board has a BLE bridge |
| `lora_rf` | LoRa RF transmit / receive | Model code position 1 is `L` or `M` |
| `i2c` | I2C bus communication (e.g. SHT40) | Board carries an I2C sensor |
| `rs485` | RS485 / Modbus transceiver | Interface is RS485 |
| `relay_test` | Relay switching output | Board has a relay output |
| `analog_v` | Analog voltage input | Board has an analog voltage input |
| `analog_c` | Analog current input (4–20 mA) | Board has a 4–20 mA input |
| `pwr_in` | Power input rail | Model code position 2 is `P` |
| `pwr_out` | Power output rail | Board supplies power to an external sensor |
| `led_test` | Status / indicator LED | Board has an indicator LED |
| `capacitor_charge` | Supercapacitor / storage charge circuit | Model code position 2 is `B` |
| `3volt_out` | 3 V rail output | Always — every board has this rail |

Three of these are decided by the model number alone, so they need no judgement:

- position 1 `L`/`M` → include `lora_rf`
- position 2 `B` → include `capacitor_charge`
- position 2 `P` → include `pwr_in`

Two apply to every board whatever its model: `ble` and `3volt_out`.

The rest depend on what is fitted to the board — confirm against the schematic, not the model number.

### Worked example

`MacSync-MBS-TH-X1` decodes to raw LoRa · Battery · Sensor · TH, on an I2C SHT40. Required tests: `ble` (always), `lora_rf` (M), `capacitor_charge` (B), `i2c` (SHT40 fitted), `3volt_out` (always). It has no RS485, no relay and no analog inputs, so those five keys are omitted entirely:

```json
{
  "hw_result": {
    "ble": true,
    "lora_rf": true,
    "capacitor_charge": true,
    "i2c": true,
    "3volt_out": true
  }
}
```

### The current files do not follow this rule

The `firmware` lists are correct — they are generated from the folder contents. The `hw_result` block is not: all three files carry the same ten-field sample. Each must be replaced with that board's real required key set and real measured values. Two problems are provable as they stand:

- **`MacSync_MBS_TH_X1` claims `rs485: false`** though it is an I2C temperature/humidity board. The key should be absent, not `false`.

`MS-MPV-X1` is tested on the LPO JIG with the same `Testing/` images as `MY_L3_CV_X1`. It is an RS485 board with no analog inputs, so its file records `ble`, `lora_rf`, `rs485` and `led_test` only - no `analog_v` / `analog_c` (the JIG's analog rows for an MPV board do not apply).

`MY_L3_CV_X1` records only the six tests its JIG runs (`ble`, `lora_rf`, `rs485`, `analog_v`, `analog_c`, `led_test`). The catalogue also calls for `pwr_in` (position 2 `P`) and `3volt_out`, but the LPO JIG does not measure either, so they are left out rather than written `false`; add them once the JIG tests them. Its `analog_v` / `analog_c` pass mean the board read 5 V and 10 V within ±0.025 V, and 10 mA and 20 mA within ±0.03 mA, after the JIG wrote the board's own calibration.

`MS_L5_CT_X1` (the relay controller) has no JIG firmware and no JIG run yet, so its `hw_result` is empty. When a JIG exists it also needs `relay_test`, `pwr_in` and `3volt_out` besides `ble`, `lora_rf`, `rs485`, `analog_v` and `analog_c`.

`ble` covers the BLE MCU. The JIG reaches the board through its nRF52 over BLE before anything else, and its `RESULT` JSON now carries `"ble": "OK"` / `"FAIL"` as the first `hw_result` entry. A board whose BLE does not link within 10 s fails `ble` (`STEP,0,FAIL,ble not connected in 10 s`) and the run ends there, so every other test of that board reads `FAIL` too. Only `MY_L3_CV_X1` records `ble` so far; add it to the other models' files with their real result when those boards next run on the updated JIG.

Fetch a result directly over raw HTTP:

```
https://raw.githubusercontent.com/MacnMan/Macnman_Production_Firmware_Hex_Files/main/<path>/hw_result.json
```

The same base URL serves the hex files:

```
https://raw.githubusercontent.com/MacnMan/Macnman_Production_Firmware_Hex_Files/main/<path>/<file>.hex
```

## Published firmware

| Model | Decoded | Interface | Application | Hex file |
| --- | --- | --- | --- | --- |
| `MY-L1-TH-X1` (was `MacSync-LBS-TH-X1`) | MacSync · LoRaWAN · Battery · no flash · TH · X1 | I2C (SHT40) | V1.0.0 | [MY-L1-TH-X1.hex](MacSync_LBO/MY_L1_TH_X1/Application/STM32WLE5CBU6/MY-L1-TH-X1.hex) |
| `MacSync-MBS-TH-X1` | raw LoRa · Battery · Sensor · TH · X1 | I2C (SHT40) | V1.1.0 | [MS-MBS-TH-X1.hex](MacSync_LBO/MacSync_MBS_TH_X1/Application/STM32WLE5CBU6/MS-MBS-TH-X1.hex) |
| `MacSync-MBS-DRS-X1` | raw LoRa · Battery · Sensor · DRS · X1 | Digital (door reed) | V1.1.0 | [MS-MBS-DRS-X1.hex](MacSync_LBO/MacSync_MBS_DRS_X1/Application/STM32WLE5CBU6/MS-MBS-DRS-X1.hex) |
| `MacSync-MPV-X1` | does not parse — see below | RS485 | V1.3.0 | [MS-MPV-X1.hex](MacSync_LPO/MS-MPV-X1/Application/STM32WLE5CBU6/MS-MPV-X1.hex) |
| `MY-L3-CV-X1` (was `MacSync-LPS-STD-X1`) | MacSync · LoRaWAN · DC 24 V · no flash · Converter · X1 | RS485, Analog | V1.0.0 | [MY-L3-CV-X1.hex](MacSync_LPO/MY_L3_CV_X1/Application/STM32WLE5CBU6/MY-L3-CV-X1.hex) |
| `MS-L5-CT-X1` (was `MS-LPC-ST-X1`) | MacSet · LoRaWAN · Mains (AC) · no flash · Controller · X1 | 2 relays, RS485, Analog | V1.0.0 | [MS-L5-CT-X1.hex](MacSync_LPO/MS_L5_CT_X1/Application/STM32WLE5CCU6/MS-L5-CT-X1.hex) |
| `MacSync-MBS-TH-X1` (BLE build) | BLE build of an `M`-coded model | I2C (SHT40) | _unconfirmed_ | [BLE-MS-MBS-TH-X1.hex](MacSync_LBO/MacSync_MBS_TH_X1/Application/NrF52/BLE-MS-MBS-TH-X1.hex) |
| `MacSync-MBS-DRS-X1` (BLE build) | BLE build of an `M`-coded model | Digital (door reed) | _unconfirmed_ | [BLE-MS-MBS-DRS-X1.hex](MacSync_LBO/MacSync_MBS_DRS_X1/Application/NrF52810/BLE-MS-MBS-DRS-X1.hex) |
| `MacSync-MPV-X1` (BLE build) | does not parse — see below | RS485 | _unconfirmed_ | [BLE-MS-MPV-X1.hex](MacSync_LPO/MS-MPV-X1/Application/NrF52810/BLE-MS-MPV-X1.hex) |
| `MY-L3-CV-X1` (BLE build) | BLE bridge of the LoRaWAN model, name `MS-LPS-STD-X1` | RS485, Analog | _unconfirmed_ | [BLE-MY-L3-CV-X1.hex](MacSync_LPO/MY_L3_CV_X1/Application/NrF52810/BLE-MY-L3-CV-X1.hex) |
| `MS-L5-CT-X1` (BLE build) | BLE bridge of the controller, name `MS-LPC-ST-X1` | 2 relays, RS485, Analog | _unconfirmed_ | [BLE-MS-L5-CT-X1.hex](MacSync_LPO/MS_L5_CT_X1/Application/NrF52810/BLE-MS-L5-CT-X1.hex) |

Application versions for the LoRa builds are the values reported by the firmware's own `DEVINFO` record. The nRF52 BLE builds embed no version string, so their versions are unconfirmed.

### Naming exceptions to resolve

- **`MPV` does not parse.** The third character `V` is neither `S` (Sensor) nor `D` (Datalogger), and the model has no payload segment between the code and the revision. Its firmware reports `DEVINFO=LORA,NODE,RS485,…`, so it is an RS485 device.
- **The BLE builds carry `M`-coded model numbers.** Position 1 of the code denotes LoRa, but these are nRF52 BLE images.
- **Folder `MS-MPV-X1/` uses the hyphenated file-name form**, while sibling model folders use `MacSync_…_X1` with underscores.

## File naming convention

Hex files are named for the model, not the version:

```
[BLE-]MS-<code>-<payload>-<revision>.hex
```

`MS` abbreviates the `MacSync` family; `<code>`, `<payload>` and `<revision>` are the model number segments above. The `BLE-` prefix marks an nRF52 BLE build and is absent on LoRa builds.

New-format models (since 2026-10-28) use the model number itself: `[BLE-]<model>.hex`, for example `MY-L3-CV-X1.hex` and `BLE-MY-L3-CV-X1.hex`.

## Adding a new firmware release

1. Place the `.hex` file in the matching `<device>/<MCU>/` folder.
2. Name it using the convention above.
3. **Add or update `hw_result.json` in that folder.** This step is mandatory for every new model number — derive the required key set from the model code and the board, per [Rule: list only the tests that model requires](#rule-list-only-the-tests-that-model-requires), and record real measured values. A new model must never inherit another model's file unchanged.
4. Validate the JSON parses and that its key set matches the tests that model actually has.
5. Commit with a message stating the model and version, e.g. `Add MacSync-MPV-X1 firmware V1.3.0`.
6. Add a row to the release notes below.

## Release notes

| Date | Model | Version | Notes |
| --- | --- | --- | --- |
| 2026-09-04 | `MacSync-MPV-X1` | V1.3.0 | Initial publication |
| 2026-09-04 | `MacSync-MBS-TH-X1` | V1.1.0 | Initial publication |
| 2026-09-04 | `MacSync-MBS-DRS-X1` | V1.1.0 | Initial publication |
| 2026-09-04 | BLE builds | _unconfirmed_ | Initial publication; versions pending confirmation |
| 2026-10-21 | `MacSync-LPS-STD-X1` | V1.0.0 | Initial publication (STM32 bootloader + app merged, BLE SoftDevice + app merged). No JIG firmware yet; `hw_result` is empty until the JIG test is run |
| 2026-10-26 | `MacSync-LPS-STD-X1` | JIG | JIG test firmware added under `Testing/`: board test images (STM32 `LPO_TEST_JIG`, nRF52810 `BLE_LPO_Testing_jig_V1`); JIG analog windows ±0.025 V / ±0.03 mA; `hw_result` from the LPO JIG run: `lora_rf`, `rs485`, `analog_v`, `analog_c`, `led_test` pass. Application files unchanged (V1.0.0) |
| 2026-10-27 | all models | JIG | `ble` added to the test catalogue (always required). The JIG `RESULT` now starts `hw_result` with `"ble"`, and a board whose BLE does not link within 10 s fails it. `MacSync-LPS-STD-X1` records `"ble": true` |
| 2026-10-27 | `MacSync-MPV-X1` | V1.3.0 | New BLE build (SoftDevice + app merged, name `MS-MPV-X1`); `Testing/` moved to the LPO JIG images; `hw_result`: `ble`, `lora_rf`, `rs485`, `led_test` (no analog on this board). STM32 file unchanged: V1.3.0, bootloader + app |
| 2026-10-28 | `MY-L1-TH-X1`, `MY-L3-CV-X1` | unchanged | Renamed to the new model number nomenclature: `MacSync_LBO/MacSync_LBS_TH_X1` → `MacSync_LBO/MY_L1_TH_X1`, `MacSync_LPO/MacSync_LPS_STD_X1` → `MacSync_LPO/MY_L3_CV_X1`; Application hex files renamed to `[BLE-]<model>.hex`, contents byte-identical. Testing files unchanged |
| 2026-10-28 | `MS-L5-CT-X1` | V1.0.0 | Initial publication of the LoRaWAN relay controller (was MS-LPC-ST-X1): STM32 bootloader + app merged (MD5 28ee2e37c669d6216e3b8a5203957570), BLE SoftDevice + app merged (name `MS-LPC-ST-X1`, MD5 baf8b76a1c13dd114a2b99382b253b63). No JIG firmware yet; `hw_result` is empty |

## Flashing

Use the standard Macnman production programming setup for the target MCU. Always verify after flashing, and confirm the device reports the expected firmware version before dispatch.

## Notes

- Production hex files are release artifacts — treat them as immutable once committed.
- Do not commit source code, build intermediates, or map files to this repository.

---

© Macnman Technologies. Internal production use.
