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
      msg_test_menu = {
        text = '테스트',
      },
      msg_dummy_for_sound = {
        text = 'dummy',
      },
      msg_restart_requested = {
        text = '재시작이 요청되었습니다. '
      },
      msg_restart_announce = {
        text = '초 후에 재시작합니다.'
      },
      msg_at_attack_force = {
        text = '공격 부대에'
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
      msg_specialty_desc = {
        text = 'supported special mission vehicle is '
      },
      msg_support_ondispatch = {
        text = '현재 지원 임무 수행 중입니다.'
      },
      msg_support_unable_current = {
        text = '현재 지원 가능하지 않습니다.'
      },
      msg_support_unable_finally = {
        text = '더 이상 지원 가능하지 않습니다.'
      },
      msg_attacker_eliminated = {
        text = ' 공격 부대가 소실되었습니다.'
      },
      msg_found_enemy = {
        text = {
          {
            payload = '적 차량을 발견했습니다! 처리 바랍니다!',
            roll = 0
          },
          {
            payload = 'Hello There?',
            roll = {1, 2}
          },
        },
      },
      msg_no_response = {
        text = '(응답 없음)'
      },
      msg_axis_finished = {
        text = '모든 적을 처리했습니다. 최종 지점에 도달했습니다.'
      },
      msg_axis_finished_no_left = {
        text = '남은 적은 발견되지 않았습니다. 최종 지점에 도달했습니다.'
      },
      msg_axis_finished_state = {
        text = '임무 완료.'
      },
      msg_success_msg_complete = {
        text = {
          {
            payload = '놀랍군요! 완벽한 성공입니다! 귀하는 우리 군의 귀중한 자산입니다.',
            roll = 0
          },
        },
      },
      msg_success_msg = {
        text = {
          {
            payload = '훌륭합니다! 작전에 성공했습니다!',
            roll = 0
          },
          {
            payload = '훌륭합니다! 작전에 성공했습니다! 오늘 저녁 배식은 스테이크입니다!',
            roll = {1, 2}
          },
        },
      },
      msg_failure_msg = {
        text = '작전은 실패했습니다.'
      },
      msg_paused_already = {
        text = {
          {
            payload = '이미 정지 중입니다.',
            roll = 0
          },
        }
      },
      msg_start_occupy = {
        text = '적 거점 점령을 시작합니다.'
      },
      msg_axis_occupied_no_left = {
        text = '적의 거점을 점령했습니다.'
      },
      msg_axis_occupied = {
        text = '적의 거점을 점령했습니다. 남은 적 병력을 제거 후 다음 거점으로 이동할 수 있습니다. 모든 적 차량의 위치를 표시했습니다.'
      },
      msg_axis_occupied_nosmoke = {
        text = '적의 거점을 점령했습니다. 남은 적 병력을 제거 후 다음 거점으로 이동할 수 있습니다.'
      },
      msg_axis_occupied_2 = {
        text = '적의 거점을 점령했습니다. 남은 적 병력을 제거해야 합니다. 모든 적 차량의 위치를 표시했습니다.'
      },
      msg_axis_occupied_nosmoke_2 = {
        text = '적의 거점을 점령했습니다. 남은 적 병력을 제거해야 합니다.'
      },
      msg_occupying = {
        text = '거점 점령 진행 중입니다.'
      },
      msg_garrison = {
        text = '거점 소탕 진행 중입니다.'
      },
      msg_to_next = {
        text = '모든 적을 처리했습니다. 다음 거점으로 이동합니다.'
      },
      msg_moving_already = {
        text = '이미 이동 중입니다.'
      },
      msg_under_attack = {
        text = {
          {
            payload = '공격받고 있습니다. 도움이 필요합니다!',
            roll = 0
          },
        }
      },
      msg_dispatch_returning = {
        text = {
          {
            payload = '대기 공역으로 복귀합니다.',
            roll = 0
          },
        },
      },
      msg_dispatching = {
        text = {
          {
            payload = '목표 공역으로 이동합니다.',
            roll = 0
          },
          {
            payload = '카피',
            roll = {1, 2}
          },
          {
            payload = '라저 라저',
            roll = {1, 2}
          },
        },
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
        text = '미션을 시작하려면 Other -> 준비 완료 메뉴를 선택해주세요!'
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
        }
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
      
      msg_support_start_engage = {
        text = '적기와 교전을 시작합니다.'
      },
      msg_squadron_ready = {
        text = '편대 준비되었습니다.'
      },
      msg_splashed_patrol = {
        text = {
          {
            payload = '적기를 격추했습니다.',
            roll = 0
          },
          {
            payload = '해치웠나?',
            roll = {1, 2}
          },
        },
      },
      msg_squadron_lost = {
        text = ' 편대 격추되었습니다.'
      },
      msg_squadron_member_lost = {
        text = '편대기가 격추되었습니다.'
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
    },
    en = {
  
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
