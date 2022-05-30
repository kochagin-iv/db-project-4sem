import psycopg2

with psycopg2.connect(database='org_mipt_atp_db', user='postgres', password='postgres', host='docker', port=49154) as conn:
    cur = conn.cursor()
    # Вставим еще одну команду в таблицу
    insert_request ='''
    INSERT INTO Team (team_nm) VALUES ('ATLANTS');'''
    cur.execute(insert_request)
    conn.commit()
    print("1 запись успешно вставлена")
    # Посмотрим на все команды
    view_request ='''
    SELECT * FROM Team'''
    cur.execute(view_request)
    record = cur.fetchall()
    print("Результат", record)
    # Удалим эту команду
    delete_query = """Delete from Team where team_nm = 'ATLANTS'"""
    cur.execute(delete_query)
    conn.commit()
    count = cur.rowcount
    print(count, "Запись успешно удалена")
    # Получим результат
    cur.execute("SELECT * from team")
    print("Результат", cur.fetchall())
    
    # Посмотрим сколько суммарно минут кто из игроков играл на турнире 2
    # Добавим к этому сводную таблицу с ФИО игрока и его рейтингом
    request = '''
    WITH info_table AS (
      WITH t AS (SELECT team_guest_id as team_id, SUM(time_min) as sum_minutes FROM game_info group by team_guest_id
        UNION
        SELECT team_home_id, SUM(time_min) as sum_minutes FROM game_info group by team_home_id
      )
      SELECT team_id, SUM(sum_minutes) as sum_minutes FROM t group by team_id
    )
    SELECT info_table.sum_minutes, player.player_nm, player.player_snm, player.rating from info_table INNER JOIN player on info_table.team_id = player.team_id;'''
    cur.execute(request)
    print("Результат", cur.fetchall())
