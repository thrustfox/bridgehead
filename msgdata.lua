--[[

BSD 3-Clause License

Copyright (c) 2023, thrustfox (thrustfox@gmail.com)

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]

MsgData = {
  messages = {
    kr = {
      syncAudio = true,
      content = {
        msg_test_menu = {
          text = '테스트',
        },
        msg_dummy_for_sound = {
          text = 'dummy',
        },
        msg_restart_requested = {
          text = '재시작이 요청되었습니다. ',
          audio = { 'msg_restart_requested.ogg', },
        },
        msg_restart_announce = {
          text = '%d초 후에 재시작합니다.'
        },
        msg_at_attack_force = {
          text = '공격 부대에'
        },
        msg_specialty_header = {
          text = ''
        },
        msg_specialty_footer = {
          text = '의 특수임무차량이 배치되었습니다.'
        },
        msg_type_light = {
          text = '경장갑차량'
        },
        msg_type_aaa = {
          text = '대공포'
        },
        msg_type_sam = {
          text = 'SAM'
        },
        msg_type_scout = {
          text = '기본무장차량'
        },
        msg_support_ondispatch = {
          text = '현재 지원 임무 수행 중입니다.',
          audio = { 'msg_support_ondispatch.ogg', },
        },
        msg_support_unable_current = {
          text = '현재 지원 가능하지 않습니다.',
          audio = { 'msg_support_unable_current.ogg', },
        },
        msg_support_unable_finally = {
          text = '더 이상 지원 가능하지 않습니다.',
          audio = { 'msg_support_unable_finally.ogg', },
        },
        msg_attacker_eliminated = {
          text = ' 공격 부대가 소실되었습니다.',
          audio = { 'msg_attacker_eliminated.ogg', },
        },
        msg_found_enemy = {
          text = {
            {
              payload = '적 차량을 발견했습니다! 처리 바랍니다!',
              roll = 0
            },
            {
              payload = 'Hello there?',
              roll = 2
            },
          },
          audio = { 'msg_found_enemy_1.ogg', 'msg_found_enemy_2.ogg', },
        },
        msg_no_response = {
          text = '(응답 없음)'
        },
        msg_axis_finished = {
          text = '모든 적을 처리했습니다. 최종 지점에 도달했습니다.',
          audio = { 'msg_axis_finished.ogg', },
        },
        msg_axis_finished_no_left = {
          text = '남은 적은 발견되지 않았습니다. 최종 지점에 도달했습니다.',
          audio = { 'msg_axis_finished_no_left.ogg', },
        },
        msg_axis_finished_state = {
          text = '임무 완료.',
          audio = { 'msg_axis_finished_state.ogg', },
        },
        msg_success_msg_complete = {
          text = {
            {
              payload = '놀랍군요! 완벽한 성공입니다! 귀하는 우리 군의 귀중한 자산입니다.',
              roll = 0
            },
          },
          audio = { 'msg_success_msg_complete.ogg', },
        },
        msg_success_msg = {
          text = {
            {
              payload = '훌륭합니다! 작전에 성공했습니다!',
              roll = 0
            },
            {
              payload = '훌륭합니다! 작전에 성공했습니다! 오늘 저녁 배식은 스테이크입니다!',
              roll = 2
            },
          },
          audio = { 'msg_success_msg_1.ogg', 'msg_success_msg_2.ogg', },
        },
        msg_failure_msg = {
          text = '작전은 실패했습니다.',
          audio = { 'msg_failure_msg.ogg', },
        },
        msg_paused_already = {
          text = {
            {
              payload = '이미 정지 중입니다.',
              roll = 0
            },
          },
          audio = { 'msg_paused_already.ogg', },
        },
        msg_start_occupy = {
          text = '적 거점 점령을 시작합니다.',
          audio = { 'msg_start_occupy.ogg', },
        },
        msg_axis_occupied_no_left = {
          text = '적의 거점을 점령했습니다.',
          audio = { 'msg_axis_occupied_no_left.ogg', },
        },
        msg_axis_occupied = {
          text = '적의 거점을 점령했습니다. 남은 적 병력을 제거 후 다음 거점으로 이동할 수 있습니다. 모든 적 차량의 위치를 표시했습니다.',
          audio = { 'msg_axis_occupied.ogg', },
        },
        msg_axis_occupied_nosmoke = {
          text = '적의 거점을 점령했습니다. 남은 적 병력을 제거 후 다음 거점으로 이동할 수 있습니다.',
          audio = { 'msg_axis_occupied_nosmoke.ogg', },
        },
        msg_axis_occupied_2 = {
          text = '적의 거점을 점령했습니다. 남은 적 병력을 제거해야 합니다. 모든 적 차량의 위치를 표시했습니다.',
          audio = { 'msg_axis_occupied_2.ogg', },
        },
        msg_axis_occupied_nosmoke_2 = {
          text = '적의 거점을 점령했습니다. 남은 적 병력을 제거해야 합니다.',
          audio = { 'msg_axis_occupied_nosmoke_2.ogg', },
        },
        msg_occupying = {
          text = '거점 점령 진행 중입니다.',
          audio = { 'msg_occupying.ogg', },
        },
        msg_garrison = {
          text = '거점 소탕 진행 중입니다.',
          audio = { 'msg_garrison.ogg', },
        },
        msg_to_next = {
          text = '모든 적을 처리했습니다. 다음 거점으로 이동합니다.',
          audio = { 'msg_to_next.ogg', },
        },
        msg_moving_already = {
          text = '이미 이동 중입니다.',
          audio = { 'msg_moving_already.ogg', },
        },
        msg_under_attack = {
          text = {
            {
              payload = '공격받고 있습니다. 도움이 필요합니다!',
              roll = 0
            },
          },
          audio = { 'msg_under_attack.ogg', },
        },
        msg_dispatch_returning = {
          text = {
            {
              payload = '대기 공역으로 복귀합니다.',
              roll = 0
            },
          },
          audio = { 'msg_dispatch_returning.ogg', },
        },
        msg_dispatching = {
          text = {
            {
              payload = '목표 공역으로 이동합니다.',
              roll = 0
            },
            {
              payload = '카피',
              roll = 1
            },
            {
              payload = '라저 라저',
              roll = 1
            },
          },
          audio = { 'msg_dispatching_1.ogg', 'msg_dispatching_2.ogg', 'msg_dispatching_3.ogg', },
        },
        msg_resumed_move = {
          text = {
            {
              payload = '이동을 재개합니다.',
              roll = 0
            },
            {
              payload = '한 번 해보죠!',
              roll = {1, 2}
            },
          },
          audio = { 'msg_resumed_move_1.ogg', 'msg_resumed_move_2.ogg', },
        },
        msg_stopped_move = {
          text = {
            {
              payload = '부대 정지합니다.',
              roll = 0
            },
            {
              payload = '장비를 정지합니다. 되잖아!',
              roll = {1, 2}
            },
          },
          audio = { 'msg_stopped_move_1.ogg', 'msg_stopped_move_2.ogg', },
        },
        msg_operator = {
          text = 'Operator'
        },
        msg_ready = {
          text = '준비 완료'
        },
        msg_selected = {
          text = '선택됨'
        },
        msg_basic_mode = {
          text = '기본 모드 (Lunchbox: ON)'
        },
        msg_basic_mode_no_lb = {
          text = '기본 모드 (Lunchbox: OFF)'
        },
        msg_extended_mode = {
          text = '확장 모드 (Lunchbox: ON)'
        },
        msg_extended_mode_no_lb = {
          text = '확장 모드 (Lunchbox: OFF)'
        },
        msg_init_guide = {
          text = '미션을 시작하려면 F10. Other -> 준비 완료 메뉴를 선택해주세요!'
        },
        msg_option_changed = {
          text = '옵션이 변경되었습니다.',
        },
        msg_start_operation = {
          text = {
            {
              payload = '작전을 개시합니다.',
              roll = 0
            },
          },
          audio = { 'msg_start_operation.ogg', },
        },
        msg_total = {
          text = {
            '전체'
          }
        },
        msg_move_unit = {
          text = {
            '지상군 이동'
          }
        },
        msg_stop_unit = {
          text = {
            '지상군 정지'
          }
        },
        msg_request_support = {
          text = {
            '지원'
          }
        },
        msg_report_status = {
          text = {
            '상황 보고'
          }
        },
        msg_reporting_status = {
          text = {
            '상황을 보고합니다.'
          },
          audio = { 'msg_reporting_status.ogg', },
        },
        msg_st_moving = {
          text = {
            '이동'
          }
        },
        msg_st_paused = {
          text = {
            '정지'
          }
        },
        msg_st_occupying = {
          text = {
            '점령'
          }
        },
        msg_st_garrison = {
          text = {
            '경계'
          }
        },
        msg_st_finished = {
          text = {
            '완료'
          }
        },
        msg_st_failed = {
          text = {
            '손실'
          }
        },
        msg_yes = {
          text = {
            '예'
          }
        },
        msg_no = {
          text = {
            '아니오'
          }
        },
        msg_opt_extended = {
          text = {
            '확장 모드'
          }
        },
        msg_opt_lunchbox = {
          text = {
            'Lunchbox'
          }
        },
        msg_opt_smoke = {
          text = {
            '스모크'
          }
        },
        msg_opt_difficulty = {
          text = {
            '난이도'
          }
        },
        msg_difficulty_easy = {
          text = {
            '쉬움'
          }
        },
        msg_difficulty_normal = {
          text = {
            '보통'
          }
        },
        msg_difficulty_hard = {
          text = {
            '어려움'
          }
        },
        msg_opt_lang = {
          text = {
            '언어 설정'
          }
        },
        msg_opt_voice_support = {
          text = {
            '음성 지원'
          }
        },
        
        msg_support_start_engage = {
          text = '적기와 교전을 시작합니다.',
          audio = { 'msg_support_start_engage.ogg', },
        },
        msg_squadron_ready = {
          text = '편대 준비되었습니다.',
          audio = { 'msg_squadron_ready.ogg', },
        },
        msg_splashed_patrol = {
          text = {
            {
              payload = '적기를 격추했습니다.',
              roll = 0
            },
            {
              payload = '해치웠나?',
              roll = 1
            },
          },
          audio = { 'msg_splashed_patrol_1.ogg', 'msg_splashed_patrol_2.ogg', },
        },
        msg_squadron_lost = {
          text = ' 편대 격추되었습니다.',
          audio = { 'msg_squadron_lost.ogg', },
        },
        msg_squadron_member_lost = {
          text = '편대기가 격추되었습니다.',
          audio = { 'msg_squadron_member_lost.ogg', },
        },
        msg_success_condition = {
          text = '개의 지상 부대가 최종 목표 도달시 작전은 성공입니다.'
        },
        msg_success_condition_initial = {
          text = '개의 지상 부대가 최종 목표 도달시 작전은 성공입니다.'
        },
        msg_success_condition_header = {
          text = '추가로 '
        },
        msg_success_condition_header_initial = {
          text = '총 '
        },
        msg_card_picked_header = {
          text = ''
        },
        msg_card_picked_footer = {
          text = '카드를 발견하였습니다.'
        },
        msg_card_deck_complete = {
          text = '카드 덱을 완성했습니다!'
        },
        msg_show_card_header = {
          text = '획득한 카드 - ', --'발견한 카드입니다.'
        },
        msg_total_destroyed = {
          text = '총 격파 수'
        },
        msg_total_occupied = {
          text = '총 점령 수'
        },
        msg_restart_operation = {
          text = '재시작 요청'
        },
        msg_operation_success = {
          text = '작전은 성공입니다.'
        },
        msg_operation_fail = {
          text = '작전은 실패했습니다.'
        },
        msg_step = {
          text = '단계'
        },
        msg_status = {
          text = '상태'
        },
        msg_units = {
          text = '유닛수'
        },
        msg_destroyed = {
          text = '격파수'
        },
        msg_smoked = {
          text = '스모크'
        },
        msg_guide_response = {
          text = '목표 지점 heading %d, range %d으로 진행바랍니다.'
        },
        msg_guidance = {
          text = '작전 구역'
        },
      },
    },
    en = {
      syncAudio = false,
      content = {
        msg_test_menu = {
          text = 'Test',
        },
        msg_dummy_for_sound = {
          text = 'dummy',
        },
        msg_restart_requested = {
          text = 'Restart is requested.',
        },
        msg_restart_announce = {
          text = 'Restarting in %d seconds.'
        },
        msg_at_attack_force = { 
          text = ''
        },
        msg_specialty_header = {
          text = 'The special mission vehicles were deployed as follows: '
        },
        msg_specialty_footer = {
          text = ''
        },
        msg_type_light = {
          text = 'Light armored vehicle'
        },
        msg_type_aaa = {
          text = 'Anti-aircraft artillery'
        },
        msg_type_sam = {
          text = 'SAM'
        },
        msg_type_scout = {
          text = 'Basic armored vehicle'
        },
        msg_support_ondispatch = {
          text = 'On duty currently.',
        },
        msg_support_unable_current = {
          text = 'Not available currently.',
        },
        msg_support_unable_finally = {
          text = 'No more available.',
        },
        msg_attacker_eliminated = {
          text = ' attack team eliminated.',
        },
        msg_found_enemy = {
          text = {
            {
              payload = 'Enemy vehicle found! Eliminate it!',
              roll = 0
            },
            {
              payload = 'Hello there?',
              roll = 2
            },
          },
        },
        msg_no_response = {
          text = '(No response)'
        },
        msg_axis_finished = {
          text = 'All enemies eliminated. Reached the final point.',
        },
        msg_axis_finished_no_left = {
          text = 'No enemy found in the point. Reached the final point.',
        },
        msg_axis_finished_state = {
          text = 'Mission complete',
        },
        msg_success_msg_complete = {
          text = {
            {
              payload = 'Unbelievable! It\'s a perfect success! You\'re the irreplaceable figure!',
              roll = 0
            },
          },
        },
        msg_success_msg = {
          text = {
            {
              payload = 'Great! Operation successful!',
              roll = 0
            },
            {
              payload = 'Great! Operation successful! Winner winner steak dinner!',
              roll = 2
            },
          },
        },
        msg_failure_msg = {
          text = 'Operation failed.',
        },
        msg_paused_already = {
          text = {
            {
              payload = 'Stopped already.',
              roll = 0
            },
          },
        },
        msg_start_occupy = {
          text = 'Starting occupation for enemy point.',
        },
        msg_axis_occupied_no_left = {
          text = 'Occupied enemy point.',
        },
        msg_axis_occupied = {
          text = 'Occupied enemy point. You need to eliminate remaining enemy forces before we move to next point. Marked locations of all enemy in the area.',
        },
        msg_axis_occupied_nosmoke = {
          text = 'Occupied enemy point. You need to eliminate remaining enemy forces before we move to next point.',
        },
        msg_axis_occupied_2 = {
          text = 'Occupied enemy point. You need to eliminate remaining enemy forces. Marked locations of all enemy in the area.',
        },
        msg_axis_occupied_nosmoke_2 = {
          text = 'Occupied enemy point. You need to eliminate remaining enemy forces.',
        },
        msg_occupying = {
          text = 'Occupation in progress',
        },
        msg_garrison = {
          text = 'In position for garrison',
        },
        msg_to_next = {
          text = 'All enemies eliminated. Moving to next point.',
        },
        msg_moving_already = {
          text = 'Moving already.',
        },
        msg_under_attack = {
          text = {
            {
              payload = 'We\'re under attack. Need help!',
              roll = 0
            },
          },
        },
        msg_dispatch_returning = {
          text = {
            {
              payload = 'Returning to the waiting area.',
              roll = 0
            },
          },
        },
        msg_dispatching = {
          text = {
            {
              payload = 'Moving to the designated area.',
              roll = 0
            },
            {
              payload = 'Copy',
              roll = 1
            },
            {
              payload = 'Roger roger',
              roll = 1
            },
          },
        },
        msg_resumed_move = {
          text = {
            {
              payload = 'Resume moving the vehicles.',
              roll = 0
            },
          },
        },
        msg_stopped_move = {
          text = {
            {
              payload = 'Stopping the vehicles.',
              roll = 0
            },
          },
        },
        msg_operator = {
          text = 'Operator'
        },
        msg_ready = {
          text = 'Ready'
        },
        msg_selected = {
          text = 'Selected'
        },
        msg_basic_mode = {
          text = 'Basic mode (Lunchbox: ON)'
        },
        msg_basic_mode_no_lb = {
          text = 'Basic mode (Lunchbox: OFF)'
        },
        msg_extended_mode = {
          text = 'Extended mode (Lunchbox: ON)'
        },
        msg_extended_mode_no_lb = {
          text = 'Extended mode (Lunchbox: OFF)'
        },
        msg_init_guide = {
          text = 'Please select F10. Other -> Ready menu to start mission'
        },
        msg_option_changed = {
          text = 'Option changed'
        },
        msg_start_operation = {
          text = {
            {
              payload = 'Starting the operation.',
              roll = 0
            },
          },
        },
        msg_total = {
          text = {
            'All'
          }
        },
        msg_move_unit = {
          text = {
            'Move the ground force'
          }
        },
        msg_stop_unit = {
          text = {
            'Stop the ground force'
          }
        },
        msg_request_support = {
          text = {
            'Support'
          }
        },
        msg_report_status = {
          text = {
            'Status report'
          }
        },
        msg_reporting_status = {
          text = {
            'Reporting the status.'
          },
        },
        msg_st_moving = {
          text = {
            'moving'
          }
        },
        msg_st_paused = {
          text = {
            'stopped'
          }
        },
        msg_st_occupying = {
          text = {
            'occupation'
          }
        },
        msg_st_garrison = {
          text = {
            'garrison'
          }
        },
        msg_st_finished = {
          text = {
            'complete'
          }
        },
        msg_st_failed = {
          text = {
            'loss'
          }
        },
        msg_yes = {
          text = {
            'Yes'
          }
        },
        msg_no = {
          text = {
            'No'
          }
        },
        msg_opt_extended = {
          text = {
            'Extended mode'
          }
        },
        msg_opt_lunchbox = {
          text = {
            'Lunchbox'
          }
        },
        msg_opt_smoke = {
          text = {
            'Smoke'
          }
        },
        msg_opt_difficulty = {
          text = {
            'Difficulty'
          }
        },
        msg_difficulty_easy = {
          text = {
            'Easy'
          }
        },
        msg_difficulty_normal = {
          text = {
            'Normal'
          }
        },
        msg_difficulty_hard = {
          text = {
            'Hard'
          }
        },
        msg_opt_lang = {
          text = {
            'Language'
          }
        },
        msg_opt_voice_support = {
          text = {
            'Voice support'
          }
        },
        
        msg_support_start_engage = {
          text = 'Engaging bandit',
        },
        msg_squadron_ready = {
          text = 'Squadron ready',
        },
        msg_splashed_patrol = {
          text = {
            {
              payload = 'Splash bandit',
              roll = 0
            },
          },
        },
        msg_squadron_lost = {
          text = ' squadron lost',
        },
        msg_squadron_member_lost = {
          text = 'Squadron\'s wing lost',
        },
        msg_success_condition = {
          text = ' ground forces reach the final point.'
        },
        msg_success_condition_initial = {
          text = ' ground forces reach the final point.'
        },
        msg_success_condition_header = {
          text = 'The operation is successful when the additional '
        },
        msg_success_condition_header_initial = {
          text = 'The operation is successful when '
        },
        msg_card_picked_header = {
          text = 'Got the card of '
        },
        msg_card_picked_footer = {
          text = '.'
        },
        msg_card_deck_complete = {
          text = 'Deck of the cards complete',
        },
        msg_show_card_header = {
          text = 'Found cards - ',
        },
        msg_total_destroyed = {
          text = 'Total destroys',
        },
        msg_total_occupied = {
          text = 'Total occupied',
        },
        msg_restart_operation = {
          text = 'Request to restart',
        },
        msg_operation_success = {
          text = 'The operation is SUCCESSFUL.'
        },
        msg_operation_fail = {
          text = 'The operation FAILED.'
        },
        msg_step = {
          text = 'Step'
        },
        msg_status = {
          text = 'status'
        },
        msg_units = {
          text = 'units'
        },
        msg_destroyed = {
          text = 'destroys'
        },
        msg_smoked = {
          text = 'smoke'
        },
        msg_guide_response = {
          text = 'Fly heading %d for %d.'
        },
        msg_guidance = {
          text = 'Hot zone'
        },
      },
    }
  }
}
--text = {
--  {
--    payload = '',
--    roll = 0
--  },
--  {
--    payload = '',
--    roll = {1, 2}
--  },
--},
--audio = 'test1.ogg'
--audio = { 'test2.ogg' },
--audio = { 'C:\\Users\\test3.ogg' }, x
--audio = { 'test4.ogg' },
